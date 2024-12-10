import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'dart:async';

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

        setState(() {
          widget.audioManager.isLiveStream = true;
        });

        try {
          print('Requesting live stream info...');
          await widget.audioManager.loadLiveStreamInfo().timeout(Duration(seconds: 10)); // Add timeout here
          print('Live stream info loaded successfully.');
        } on TimeoutException catch (_) {
          print('Error: Request to load live stream info timed out.');
          setState(() {
            widget.audioManager.isLiveStream = false;
          });
        } catch (e) {
          print('Error loading live stream info: $e');
          setState(() {
            widget.audioManager.isLiveStream = false;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.audioManager.isLiveStream ? Colors.blue : Colors.grey,
      ),
      child: const Text('Live'),
    );
  }
}
