import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorites';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> addFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(title)) {
      favorites.add(title);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  static Future<void> removeFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.contains(title)) {
      favorites.remove(title);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  static Future<void> toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      favorites.add(title);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<bool> isFavorite(String title) async {
    final favorites = await getFavorites();
    return favorites.contains(title);
  }
}
