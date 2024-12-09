import 'package:flutter/material.dart';
import 'audio_manager.dart';

class LiveButton extends StatefulWidget {
  final AudioManager audioManager;

  const LiveButton({Key? key, required this.audioManager}) : super(key: key);

  @override
  _LiveButtonState createState() => _LiveButtonState();
}

class _LiveButtonState extends State<LiveButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Prevent redundant calls if already live or loading
        if (widget.audioManager.isLiveStream || widget.audioManager.isLoading) {
          return;
        }

        widget.audioManager.isLiveStream = true;
        await widget.audioManager.loadLiveStreamInfo();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.audioManager.isLiveStream ? Colors.blue : Colors.grey,
      ),
      child: const Text('Live'),
    );
  }
}
