import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class AudioManager {
  final VoidCallback onUpdate;

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isLiveStream = true;
  bool isLoading = false;
  double currentVolume = 0.5;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Duration elapsedTime = Duration.zero;
  String streamUrl = "";
  String artistName = "Unknown Artist";
  String albumName = "Unknown Album";
  String albumArtUrl = "";
  Timer? _elapsedTimer;

  AudioManager({required this.onUpdate}) {
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
      if (!isPlaying && isLiveStream) {
        stopElapsedTimeSimulation();
      }
      onUpdate();
    });
  }

  Future<void> loadMP3StreamInfo(
      String url, String artist, String title) async {
    await stop();
    isLiveStream = false;
    artistName = artist;
    albumName = title;
    streamUrl = url;
    onUpdate();
  }

  Future<void> loadLiveStreamInfo() async {
    if (isLoading) return; // Prevent multiple calls
    _setLoading(true);
    try {
      final response = await http
          .get(Uri.parse("https://radio.kunststaub.fm/api/nowplaying"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final nowPlaying = data[0]['now_playing'];
          final song = nowPlaying['song'];
          streamUrl = data[0]['station']['listen_url'] ?? streamUrl;
          artistName = song['artist'] ?? "Unknown Artist";
          albumName = song['title'] ?? "Unknown Title";
          albumArtUrl = song['art'] ?? "";
          final newElapsedTime = Duration(seconds: nowPlaying['elapsed'] ?? 0);
          final newTotalDuration =
              Duration(seconds: nowPlaying['duration'] ?? 0);
          if (newTotalDuration.inSeconds > 5) {
            totalDuration = newTotalDuration;
          }
          if (newElapsedTime.inSeconds > 0) {
            elapsedTime = newElapsedTime;
          }
          onUpdate();
        }
      }
    } catch (e) {
      print('Error fetching live stream info: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> play() async {
    if (isLoading) return;
    _setLoading(true);
    try {
      if (isLiveStream) {
        if (streamUrl.isNotEmpty) {
          await _audioPlayer.play(UrlSource(streamUrl));
          startElapsedTimeSimulation();
        }
      } else {
        await _audioPlayer.resume();
      }
      isPlaying = true;
    } finally {
      _setLoading(false);
    }
    onUpdate();
  }

  Future<void> stop() async {
    if (isLoading) return;
    _setLoading(true);
    try {
      await _audioPlayer.stop();
      isPlaying = false;
      stopElapsedTimeSimulation();
      //elapsedTime = Duration.zero;
    } finally {
      _setLoading(false);
    }
    onUpdate();
  }

  void startElapsedTimeSimulation() {
    stopElapsedTimeSimulation();
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedTime += Duration(seconds: 1);
      if (elapsedTime >= totalDuration && totalDuration.inSeconds > 5) {
        timer.cancel();
      }
      onUpdate();
    });
  }

  void stopElapsedTimeSimulation() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void setVolume(double volume) {
    currentVolume = volume;
    _audioPlayer.setVolume(volume);
    onUpdate();
  }

  void toggleMute() {
    setVolume(currentVolume > 0 ? 0 : 0.5);
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
    stopElapsedTimeSimulation();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _setLoading(bool value) {
    print('setLoading: $value');
    isLoading = value;
    onUpdate();
  }

  void togglePlay() async {
    if (isLiveStream) {
      isPlaying ? await stop() : await play();
    } else {
      isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
    }
    isPlaying = !isPlaying;
    onUpdate();
  }
}
