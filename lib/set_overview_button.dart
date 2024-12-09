import 'package:flutter/material.dart';
import 'artist_list_screen.dart';
import 'audio_manager.dart';

class SetOverviewButton extends StatelessWidget {
  final AudioManager audioManager;

  SetOverviewButton({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await audioManager.stop();
        audioManager.isLiveStream = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistListScreen(
              onSetSelected: (url, artist, title) {
                audioManager.playMP3(url, artist, title);
              },
            ),
          ),
        );
      },
      child: Text('Set Übersicht'),
      style: ElevatedButton.styleFrom(
        backgroundColor: !audioManager.isLiveStream ? Colors.blue : Colors.grey,
      ),
    );
  }
}
