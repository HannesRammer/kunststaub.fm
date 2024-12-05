import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioManager {
  final BuildContext context;
  final VoidCallback onUpdate;
  late AudioPlayer _audioPlayer;
  bool isLiveStream = false;
  bool isPlaying = false;
  double currentVolume = 0.5;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Duration elapsedTime = Duration.zero;
  String streamUrl = "";
  String artistName = "";
  String albumName = "";
  String channelName = "";
  String albumArtUrl = "";
  Timer? _elapsedTimer;

  AudioManager(this.context, {required this.onUpdate}) {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(currentVolume);

    _audioPlayer.onDurationChanged.listen((duration) {
      if (duration.inSeconds > 5) {
        totalDuration = duration;
        onUpdate();
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!isLiveStream) {
        currentPosition = position;
        onUpdate();
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      onUpdate();
    });
  }

  Future<void> loadLiveStreamInfo() async {
    try {
      print('Fetching live  stream info...');
      final String nowPlayingUrl = "https://radio.kunststaub.fm/api/nowplaying";
      final response = await http.get(Uri.parse(nowPlayingUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final nowPlaying = data[0]['now_playing'];
          final song = nowPlaying['song'];

          // Update stream URL from the API response
          streamUrl = data[0]['station']['listen_url'] ?? streamUrl;

          final newArtistName = song['artist'] ?? "Künstlername";
          final newAlbumName = song['title'] ?? "Mixname";
          final newChannelName = song['album'] ?? "Channelname";
          final newAlbumArtUrl = song['art'] ?? "";
          final newElapsed = Duration(seconds: nowPlaying['elapsed'] ?? 0);
          final newTotalDuration = Duration(seconds: nowPlaying['duration'] ?? 0);

          if (newTotalDuration.inSeconds > 5 && totalDuration != newTotalDuration) {
            totalDuration = newTotalDuration;
          }
          if (newElapsed.inSeconds > 5 && elapsedTime != newElapsed) {
            elapsedTime = newElapsed;
          }
          if (artistName != newArtistName) {
            artistName = newArtistName;
          }
          if (albumName != newAlbumName) {
            albumName = newAlbumName;
          }
          if (channelName != newChannelName) {
            channelName = newChannelName;
          }
          if (albumArtUrl != newAlbumArtUrl) {
            albumArtUrl = newAlbumArtUrl;
          }

          onUpdate();
        }
      }
    } catch (e) {
      print('Error fetching live stream info: $e');
    }
  }

  Future<void> play() async {
    if (isLiveStream) {
      await loadLiveStreamInfo();
      onUpdate();
      _audioPlayer.play(UrlSource(streamUrl));
    } else {
      await _audioPlayer.resume();
    }
    isPlaying = true;
    onUpdate();
  }

  Future<void> playMP3(String url, String artist, String title) async {
    await stop();
    isLiveStream = false;
    artistName = artist;
    albumName = title;
    await _audioPlayer.play(UrlSource(url));
    isPlaying = true;
    onUpdate();
  }

  void startElapsedTimeSimulation() {
    _elapsedTimer?.cancel(); // Cancel any existing timer
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isPlaying && isLiveStream) {
        elapsedTime += Duration(seconds: 1);
        currentPosition = elapsedTime;
        onUpdate();
      }
    });
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying = false;
    _elapsedTimer?.cancel();
    onUpdate();
  }

  void togglePlay() {
    if (isPlaying) {
      _audioPlayer.pause();
      isPlaying = false;
    } else {
      play();
    }
    onUpdate();
  }

  void setVolume(double volume) {
    currentVolume = volume;
    _audioPlayer.setVolume(volume);
    onUpdate();
  }

  void toggleMute() {
    if (currentVolume > 0) {
      _audioPlayer.setVolume(0);
      currentVolume = 0;
    } else {
      _audioPlayer.setVolume(0.5);
      currentVolume = 0.5;
    }
    onUpdate();
  }

  Future<void> seek(Duration position) async {
    if (!isLiveStream && position.inSeconds <= totalDuration.inSeconds) {
      await _audioPlayer.seek(position);
      currentPosition = position;
      onUpdate();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _elapsedTimer?.cancel();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
