import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'favorites_manager.dart';
import 'live_button.dart';
import 'set_overview_button.dart';

class PlayerScreen extends StatefulWidget {
  final AudioManager audioManager;
  final bool isEmbedded;

  const PlayerScreen(
      {Key? key, required this.audioManager, this.isEmbedded = false})
      : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver {
  late AudioManager audioManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audioManager = widget.audioManager;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEmbedded
        ? _buildEmbeddedPlayer()
        : _buildFullScreenPlayer();
  }

  Widget _buildEmbeddedPlayer() {
    return _buildPlayerContent();
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
          audioManager.isLoading
              ? const CircularProgressIndicator()
              : audioManager.albumArtUrl.isNotEmpty
                  ? Image.network(
                      audioManager.albumArtUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(height: 100, width: 100, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            audioManager.artistName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            audioManager.albumName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiveButton(audioManager: audioManager),
              const SizedBox(width: 10),
              SetOverviewButton(audioManager: audioManager),
              const SizedBox(width: 10),
              FutureBuilder<bool>(
                future: FavoritesManager.isFavorite(audioManager.albumName),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      await FavoritesManager.toggleFavorite(
                          audioManager.albumName);
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                onPressed: () {
                  audioManager.togglePlay();
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
              Slider(
                value: audioManager.currentVolume,
                max: 1.0,
                min: 0.0,
                onChanged: audioManager.setVolume,
                activeColor: Colors.white,
                inactiveColor: Colors.white38,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Slider(
            value: audioManager.isLiveStream
                ? audioManager.elapsedTime.inSeconds.toDouble()
                : audioManager.currentPosition.inSeconds.toDouble(),
            max: audioManager.totalDuration.inSeconds
                .toDouble()
                .clamp(1.0, double.infinity),
            onChanged: audioManager.isLiveStream
                ? null
                : (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await audioManager.seek(newPosition);
                  },
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),
          Text(
            "${audioManager.formatDuration(audioManager.elapsedTime)} / ${audioManager.formatDuration(audioManager.totalDuration)}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
