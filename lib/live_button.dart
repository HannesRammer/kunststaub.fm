import 'package:flutter/material.dart';
import 'audio_manager.dart';

class LiveButton extends StatelessWidget {
  final AudioManager audioManager;
  final bool liveStreamInfoLoaded;
  final Future<void> Function() onLoadLiveStreamInfo;

  LiveButton({
    required this.audioManager,
    required this.liveStreamInfoLoaded,
    required this.onLoadLiveStreamInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await audioManager.stop();
        audioManager.isLiveStream = true;
        if (!liveStreamInfoLoaded) {
          await onLoadLiveStreamInfo(); // Load live stream info if not loaded
        }
      },
      child: Text('Live'),
      style: ElevatedButton.styleFrom(
        backgroundColor: audioManager.isLiveStream ? Colors.blue : Colors.grey,
      ),
    );
  }
}
