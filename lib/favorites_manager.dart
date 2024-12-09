import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static List<String> _favorites = [];

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites') ?? [];
  }

  static bool isFavorite(String title) {
    return _favorites.contains(title);
  }

  static Future<void> toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.contains(title)) {
      _favorites.remove(title);
    } else {
      _favorites.add(title);
    }
    await prefs.setStringList('favorites', _favorites);
  }

  static List<String> get favorites => _favorites;
}
