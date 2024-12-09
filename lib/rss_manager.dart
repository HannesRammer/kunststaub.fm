import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class RSSManager {
  final String rssFeedUrl;

  RSSManager({required this.rssFeedUrl});

  /// Fetch RSS feed and save the parsed sets to SharedPreferences
  Future<void> fetchAndSaveRSSFeed() async {
    try {
      final response = await http.get(Uri.parse(rssFeedUrl));
      if (response.statusCode == 200) {
        final rssFeed = response.body;
        final sets = parseRSSFeed(rssFeed);
        await saveSetsToSharedPrefs(sets);
      } else {
        throw Exception('Failed to fetch RSS feed');
      }
    } catch (e) {
      print('Error fetching RSS feed: $e');
    }
  }

  /// Parse RSS feed and return a list of sets
  List<Map<String, String>> parseRSSFeed(String rssFeed) {
    final document = XmlDocument.parse(rssFeed);
    final items = document.findAllElements('item');
    final sets = items.map((item) {
      final title = item.findElements('title').first.text;
      final url = item.findElements('link').first.text;
      final pubDate = item.findElements('pubDate').first.text;
      final artist = item.getElement('itunes:author')?.text ?? '';
      final albumArt = item.getElement('itunes:image')?.getAttribute('href') ?? '';

      return {
        'title': title,
        'url': url,
        'pubDate': pubDate,
        'artist': artist,
        'albumArt': albumArt,
      };
    }).toList();
    return sets;
  }

  /// Save sets to SharedPreferences
  Future<void> saveSetsToSharedPrefs(List<Map<String, String>> sets) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSets = json.encode(sets);
    await prefs.setString('savedSets', encodedSets);
    print('RSS feed saved successfully.');
  }

  /// Load sets from SharedPreferences
  Future<List<Map<String, String>>> loadSetsFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedSets = prefs.getString('savedSets');
    if (cachedSets != null) {
      return List<Map<String, String>>.from(json.decode(cachedSets));
    }
    return [];
  }
}
