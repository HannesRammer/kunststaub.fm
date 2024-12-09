import 'package:flutter/material.dart';
import 'rss_manager.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const rssUrl = 'https://kunststaub.fm/feed.rss'; // Replace with actual RSS URL
  final RSSManager rssManager = RSSManager(rssFeedUrl: rssUrl);

  // Fetch and save RSS data to shared preferences
  await rssManager.fetchAndSaveRSSFeed();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kunststaub FM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
