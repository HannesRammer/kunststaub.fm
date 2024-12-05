import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'artist_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';
import 'live_button.dart';
import 'set_overview_button.dart';

class PlayerScreen extends StatefulWidget {
  final bool isEmbedded;
  PlayerScreen({this.isEmbedded = false});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late AudioManager audioManager;
  bool liveStreamInfoLoaded = false;
  bool isLoading = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (audioManager.isPlaying) {
        audioManager.togglePlay();
      }
    } else if (state == AppLifecycleState.resumed && !audioManager.isPlaying) {
      audioManager.togglePlay();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Register the observer

    audioManager = AudioManager(context, onUpdate: () {
      setState(() {
        isLoading = false;
      });
    });

    // Load live stream info and set the initial state to live stream
    _initializeLiveStream();
  }

  Future<void> _initializeLiveStream() async {
    await audioManager.stop();
    setState(() {
      audioManager.isLiveStream = true;
    });
    await _loadLiveStreamInfo();
  }

  Future<void> _loadLiveStreamInfo() async {
    setState(() {
      isLoading = true;
    });
    await audioManager.loadLiveStreamInfo();
    setState(() {
      liveStreamInfoLoaded = true;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildEmbeddedPlayer();
  }

  Widget _buildEmbeddedPlayer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          audioManager.albumArtUrl.isNotEmpty
              ? Image.network(audioManager.albumArtUrl, height: 100, width: 100)
              : Container(height: 100, width: 100, color: Colors.grey),
          SizedBox(height: 10),
          Text(audioManager.artistName, style: TextStyle(color: Colors.white, fontSize: 18)),
          Text(audioManager.albumName, style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiveButton(
                audioManager: audioManager,
                liveStreamInfoLoaded: liveStreamInfoLoaded,
                onLoadLiveStreamInfo: _loadLiveStreamInfo,
              ),
              SizedBox(width: 10),
              SetOverviewButton(
                audioManager: audioManager,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : IconButton(
                icon: Icon(
                  audioManager.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (audioManager.isLiveStream) {
                    if (audioManager.isPlaying) {
                      await audioManager.stop();
                    } else {
                      if (liveStreamInfoLoaded) {
                        setState(() {
                          audioManager.currentPosition = audioManager.elapsedTime;
                        });
                        audioManager.startElapsedTimeSimulation(); // Start timer simulation for elapsed time
                        await audioManager.play();
                      } else {
                        await _loadLiveStreamInfo();
                        if (audioManager.totalDuration > Duration.zero) {
                          setState(() {
                            audioManager.currentPosition = audioManager.elapsedTime;
                          });
                          audioManager.startElapsedTimeSimulation(); // Start timer simulation for elapsed time
                          await audioManager.play();
                        }
                      }
                    }
                  } else {
                    audioManager.togglePlay();
                  }
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  audioManager.currentVolume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: audioManager.toggleMute,
              ),
              Slider(
                value: audioManager.currentVolume,
                max: 1.0,
                min: 0.0,
                onChanged: (value) {
                  audioManager.setVolume(value);
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white38,
              ),
            ],
          ),
          Slider(
            value: audioManager.isLiveStream
                ? audioManager.currentPosition.inSeconds.toDouble() // Simulated elapsed time for live stream
                : audioManager.currentPosition.inSeconds.toDouble().clamp(
                0.0,
                audioManager.totalDuration.inSeconds.toDouble()),
            max: audioManager.totalDuration.inSeconds.toDouble() > 0
                ? audioManager.totalDuration.inSeconds.toDouble()
                : 1.0,
            onChanged: audioManager.isLiveStream
                ? null // Disable slider for live stream
                : (value) async {
              // Seek to the selected position for MP3
              await audioManager.seek(Duration(seconds: value.toInt()));
              setState(() {
                audioManager.currentPosition = Duration(seconds: value.toInt());
              });
            },
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),

          Text(
            "${audioManager.formatDuration(audioManager.currentPosition)} / ${audioManager.formatDuration(audioManager.totalDuration)}",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
