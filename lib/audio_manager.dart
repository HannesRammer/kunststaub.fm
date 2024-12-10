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
  String streamUrl = "";
  String artistName = "Unknown Artist";
  String albumName = "Unknown Album";
  String albumArtUrl = "";
  Timer? _elapsedTimer;
  Timer? _debounceTimer;

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
      //we shall only react on position change listener when not livestream
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

  Future<void> loadMP3StreamInfo(String url, String artist, String title) async {
    await stop();
    isLiveStream = false;
    artistName = artist;
    albumName = title;
    streamUrl = url;
    currentPosition = Duration.zero; // Reset currentPosition
    final startSetSourceTime = DateTime.now();
    print('Setting source URL: $streamUrl');
    await _audioPlayer.setSourceUrl(streamUrl); // Pre-load the stream URL
    final endSetSourceTime = DateTime.now();
    print('Time taken to set source URL: ${endSetSourceTime.difference(startSetSourceTime).inMilliseconds} ms');
    await seek(Duration.zero); // Reset to zero
    onUpdate();
  }

// doc for swagger api radio
// https://radio.kunststaub.fm/docs/api/#/Now%20Playing/getAllNowPlaying

  Future<void> loadLiveStreamInfo() async {
    if (isLoading) {
      print('loadLiveStreamInfo skipped due to isLoading being true.');
      return;
    }
    _setLoading(true);
    print('loadLiveStreamInfo started.');

    try {
      print('Requesting live stream info...');
      final startTime = DateTime.now();
      final response = await http.get(Uri.parse("https://radio.kunststaub.fm/api/nowplaying"));
      final endTime = DateTime.now();
      print('Response status: ${response.statusCode}');
      print('Time taken for HTTP request: ${endTime.difference(startTime).inMilliseconds} ms');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data.isNotEmpty) {
          print('Live stream info fetched: $data');

          final nowPlaying = data[0]['now_playing'];
          final song = nowPlaying['song'];
          //streamUrl = data[0]['station']['listen_url'] ?? streamUrl;
          streamUrl = "https://radio.kunststaub.fm/listen/kunststaub/radio";
          artistName = song['artist'] ?? "Unknown Artist";
          albumName = song['title'] ?? "Unknown Title";
          albumArtUrl = song['art'] ?? "";
          final newElapsedTime = Duration(seconds: nowPlaying['elapsed'] ?? 0);
          final newTotalDuration = Duration(seconds: nowPlaying['duration'] ?? 0);
          if (newTotalDuration.inSeconds > 5) {
            totalDuration = newTotalDuration;
            await seek(newElapsedTime); // Set elapsed time from API
          }
          // Preload the stream URL
          await _audioPlayer.setSourceUrl(streamUrl);
          onUpdate();
        }
      }
    } on TimeoutException catch (_) {
      print('Error: Request to load live stream info timed out.');
    } catch (e) {
      print('Error fetching live stream info: $e');
    } finally {
      _setLoading(false);
      print('loadLiveStreamInfo finished.');
    }
  }

  Future<void> play() async {
    //only  dont return
    if (isPlaying) return;

    isPlaying = true;
    onUpdate();

    try {
      if (streamUrl.isNotEmpty) {
        print('Playing stream: $streamUrl');
        final startPlayTime = DateTime.now();
        await _audioPlayer.resume(); // Resume playback
        final endPlayTime = DateTime.now();
        print('Time taken to start playback: ${endPlayTime.difference(startPlayTime).inMilliseconds} ms');
        if (isLiveStream) {
          startElapsedTimeSimulation();
        }
      }
    } catch (e) {
      print('Error playing stream: $e');
      isPlaying = false;
    }
    onUpdate();
  }

  Future<void> stop() async {
    if (!isPlaying) return;
    isPlaying = false;
    try {
      print('Stopping playback');
      final startStopTime = DateTime.now();
      await _audioPlayer.stop();
      final endStopTime = DateTime.now();
      print('Time taken to stop playback: ${endStopTime.difference(startStopTime).inMilliseconds} ms');
      if (isLiveStream) {
        stopElapsedTimeSimulation();
      }
    } catch (e) {
      print('Error stopping playback: $e');
    }
    onUpdate();
  }

  void startElapsedTimeSimulation() {
    stopElapsedTimeSimulation();
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      currentPosition += Duration(seconds: 1);
      if (currentPosition >= totalDuration && totalDuration.inSeconds > 5) {
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
    if (position.inSeconds <= totalDuration.inSeconds) {
      final startSeekTime = DateTime.now();
      await _audioPlayer.seek(position);
      final endSeekTime = DateTime.now();
      print('Time taken to seek: ${endSeekTime.difference(startSeekTime).inMilliseconds} ms');
      currentPosition = position;
    } else {
      print('Seek operation is not allowed for live streams.');
    }
    onUpdate();
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

  Future<void> togglePlay() async {
    if (isPlaying) {
      await stop();
    } else {
      await play();
    }
    onUpdate();
  }
}
