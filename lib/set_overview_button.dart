import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'artist_list_screen.dart';

class SetOverviewButton extends StatelessWidget {
  final AudioManager audioManager;

  SetOverviewButton({
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await audioManager.stop();
        audioManager.isLiveStream = false;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ArtistListScreen(onSetSelected: (setUrl, artist, title, elapsed, duration) {
                audioManager.playMP3(setUrl);
              })),
        );
      },
      child: Text('Set Übersicht'),
      style: ElevatedButton.styleFrom(
        backgroundColor: !audioManager.isLiveStream ? Colors.blue : Colors.grey,
      ),
    );
  }
}
