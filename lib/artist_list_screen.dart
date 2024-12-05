import 'package:flutter/material.dart';
import 'artist_links.dart';

class ArtistListScreen extends StatefulWidget {
  final void Function(String, String, String) onSetSelected;

  ArtistListScreen({required this.onSetSelected});

  @override
  _ArtistListScreenState createState() => _ArtistListScreenState();
}

class _ArtistListScreenState extends State<ArtistListScreen> {
  String searchQuery = '';
  bool sortByDate = false; // Flag for sorting order

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, String>> artists = artistLinks.entries.toList();

    // Sort artists by name or date
    if (sortByDate) {
      artists.sort((a, b) {
        final datePattern = RegExp(r'\((\d{2}\.\d{2}\.\d{2})\)');
        final matchA = datePattern.firstMatch(a.key);
        final matchB = datePattern.firstMatch(b.key);

        if (matchA != null && matchB != null) {
          final dateA = DateTime.parse('20' + matchA.group(1)!.split('.').reversed.join());
          final dateB = DateTime.parse('20' + matchB.group(1)!.split('.').reversed.join());
          return dateA.compareTo(dateB);
        }
        return a.key.compareTo(b.key);
      });
    } else {
      artists.sort((a, b) => a.key.compareTo(b.key));
    }

    // Filter artists by search query
    if (searchQuery.isNotEmpty) {
      artists = artists
          .where((artist) =>
          artist.key.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Artist List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Text Search',
                      labelStyle: TextStyle(color: Colors.black), // Ensure the label is visible
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black), // Ensure the entered text is visible
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Text('Name', style: TextStyle(color: Colors.black)),
                Switch(
                  value: sortByDate,
                  onChanged: (value) {
                    setState(() {
                      sortByDate = value;
                    });
                  },
                ),
                Text('Date', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                String artist = artists[index].key;
                String link = artists[index].value;

                // Extract artist name and title
                String artistName = artist.split(' @ ')[0];
                String title = artist.split('@').last.trim();



                return ListTile(
                  title: Text(
                    artist,
                    style: TextStyle(color: Colors.black), // Ensure artist names are visible
                  ),
                  onTap: () {
                    widget.onSetSelected(link, artistName, title);
                    Navigator.pop(context);
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
