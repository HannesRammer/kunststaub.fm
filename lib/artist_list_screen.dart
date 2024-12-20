import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'favorites_manager.dart';
import 'package:flutter/foundation.dart';

class ArtistListScreen extends StatefulWidget {
  final void Function(String url, String artist, String title) onSetSelected;

  ArtistListScreen({required this.onSetSelected});

  @override
  _ArtistListScreenState createState() => _ArtistListScreenState();
}

class _ArtistListScreenState extends State<ArtistListScreen> {
  List<Map<String, String>> sets = [];
  List<Map<String, String>> filteredSets = [];
  String searchQuery = '';
  bool sortByDate = false;
  Map<String, ValueNotifier<bool>> favoriteNotifiers = {};

  @override
  void initState() {
    super.initState();
    _loadSetsFromSharedPrefs();
  }

  Future<void> _loadSetsFromSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSets = prefs.getString('savedSets');
      if (cachedSets != null) {
        final decodedSets = List<Map<String, dynamic>>.from(json.decode(cachedSets));
        sets = decodedSets.map((item) => item.map((key, value) => MapEntry(key, value.toString()))).toList();
        filteredSets = List.from(sets);
        for (var set in sets) {
          final title = set['title'] ?? 'Unknown Title';
          favoriteNotifiers[title] = ValueNotifier(await FavoritesManager.isFavorite(title));
          // Preload images
          if (set['albumArt'] != null && set['albumArt']!.isNotEmpty) {
            precacheImage(NetworkImage(set['albumArt']!), context);
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Error loading sets from SharedPreferences: $e');
    }
  }

  @override
  void dispose() {
    for (var notifier in favoriteNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _filterSets(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredSets = sets.where((set) {
        final title = set['title']?.toLowerCase() ?? '';
        final artist = set['artist']?.toLowerCase() ?? '';
        return title.contains(searchQuery) || artist.contains(searchQuery);
      }).toList();
    });
  }

  void _sortSets() {
    setState(() {
      if (sortByDate) {
        filteredSets.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
          return dateA.compareTo(dateB);
        });
      } else {
        filteredSets.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSetsFromSharedPrefs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterSets,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text('Sort by Date'),
                Switch(
                  value: sortByDate,
                  onChanged: (value) {
                    setState(() {
                      sortByDate = value;
                      _sortSets();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSets.isEmpty
                ? const Center(child: Text('No sets found'))
                : ListView.builder(
                    itemCount: filteredSets.length,
                    itemBuilder: (context, index) {
                      final set = filteredSets[index];
                      final title = set['title'] ?? 'Unknown Title';
                      return ValueListenableBuilder<bool>(
                        valueListenable: favoriteNotifiers[title]!,
                        builder: (context, isFavorite, child) {
                          return ListTile(
                            leading: set['albumArt'] != null
                                ? Image.network(
                                    set['albumArt']!,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note),
                                  )
                                : const Icon(Icons.music_note),
                            title: Text(set['title'] ?? 'Unknown Title'),
                            subtitle: Text(set['artist'] ?? 'Unknown Artist'),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.star,
                                color: isFavorite ? Colors.yellow : Colors.grey,
                              ),
                              onPressed: () async {
                                await FavoritesManager.toggleFavorite(title);
                                favoriteNotifiers[title]!.value = !isFavorite;
                              },
                            ),
                            onTap: () {
                              widget.onSetSelected(
                                set['url'] ?? '',
                                set['artist'] ?? '',
                                set['title'] ?? '',
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
