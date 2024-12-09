import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';
import 'live_button.dart';
import 'set_overview_button.dart';
import 'favorites_manager.dart';

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
    return widget.isEmbedded ? _buildEmbeddedPlayer() : _buildFullScreenPlayer();
  }

  Widget _buildFullScreenPlayer() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
      ),
      body: Center(
        child: _buildPlayerContent(),
      ),
    );
  }

  Widget _buildEmbeddedPlayer() {
    return _buildPlayerContent();
  }

  Widget _buildPlayerContent() {
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
          // Album Art
          audioManager.albumArtUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(audioManager.albumArtUrl,
                height: 100, width: 100, fit: BoxFit.cover),
          )
              : Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          const SizedBox(height: 10),

          // Artist and Title
          Text(
            audioManager.artistName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Text(
            audioManager.albumName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Control Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiveButton(
                audioManager: audioManager,
                liveStreamInfoLoaded: liveStreamInfoLoaded,
                onLoadLiveStreamInfo: _loadLiveStreamInfo,
              ),
              const SizedBox(width: 10),
              SetOverviewButton(
                audioManager: audioManager,
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: FavoritesManager.isFavorite(audioManager.albumName)
                      ? Colors.yellow
                      : Colors.white,
                ),
                onPressed: () async {
                  await FavoritesManager.toggleFavorite(audioManager.albumName);
                  setState(() {}); // Refresh the UI
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Playback Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  audioManager.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () async {
                  if (audioManager.isLiveStream) {
                    if (audioManager.isPlaying) {
                      await audioManager.stop();
                    } else {
                      await audioManager.play();
                    }
                  } else {
                    audioManager.togglePlay();
                  }
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  audioManager.currentVolume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: audioManager.toggleMute,
              ),
              Expanded(
                child: Slider(
                  value: audioManager.currentVolume,
                  max: 1.0,
                  min: 0.0,
                  onChanged: (value) {
                    audioManager.setVolume(value);
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Slider
          Slider(
            value: audioManager.isLiveStream
                ? audioManager.currentPosition.inSeconds.toDouble()
                : audioManager.currentPosition.inSeconds
                .clamp(0.0, audioManager.totalDuration.inSeconds)
                .toDouble(),
            max: audioManager.totalDuration.inSeconds.toDouble() > 0
                ? audioManager.totalDuration.inSeconds.toDouble()
                : 1.0,
            onChanged: audioManager.isLiveStream
                ? null
                : (value) async {
              await audioManager.seek(Duration(seconds: value.toInt()));
              setState(() {
                audioManager.currentPosition =
                    Duration(seconds: value.toInt());
              });
            },
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),

          // Time Text
          Text(
            "${audioManager.formatDuration(audioManager.currentPosition)} / ${audioManager.formatDuration(audioManager.totalDuration)}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
