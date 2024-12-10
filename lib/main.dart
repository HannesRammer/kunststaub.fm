import 'dart:async';

import 'package:flutter/material.dart';
import 'rss_manager.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const rssUrl = 'https://kunststaub.fm/feed.rss'; // Replace with actual RSS URL
  final RSSManager rssManager = RSSManager(rssFeedUrl: rssUrl);

  // Fetch and save RSS data to shared preferences
  try {
    print('Requesting RSS feed...');
    await rssManager.fetchAndSaveRSSFeed().timeout(Duration(seconds: 10)); // Add timeout here
    print('RSS feed saved successfully.');
  } on TimeoutException catch (_) {
    print('Error: Request to fetch RSS feed timed out.');
  } catch (e) {
    print('Error fetching RSS feed: $e');
  }

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
