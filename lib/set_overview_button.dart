import 'package:flutter/material.dart';
import 'artist_list_screen.dart';
import 'audio_manager.dart';

class SetOverviewButton extends StatefulWidget {
  final AudioManager audioManager;

  const SetOverviewButton({Key? key, required this.audioManager}) : super(key: key);

  @override
  _SetOverviewButtonState createState() => _SetOverviewButtonState();
}

class _SetOverviewButtonState extends State<SetOverviewButton> {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistListScreen(
              onSetSelected: (url, artist, title) {
                widget.audioManager.loadMP3StreamInfo(url, artist, title);

              },
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.audioManager.isLiveStream ? Colors.grey : Colors.blue,
      ),
      child:  const Text('Sets Overview'),
    );
  }
}
