import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'player_screen.dart';
import 'social_media_links.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AudioManager audioManager;

  @override
  void initState() {
    super.initState();
    audioManager =
        AudioManager(onUpdate: () {
      setState(() {}); // Update the UI when the audio manager notifies us

    });
    audioManager.loadLiveStreamInfo();

  }

  @override
  void dispose() {
    audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunststaub FM'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Kunststaub FM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Spiel starten'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/saturn_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:  PlayerScreen(
                        isEmbedded: true,
                        audioManager: audioManager,
                      ),
              ),
              SocialMediaLinks(),
            ],
          ),
        ],
      ),
    );
  }
}
