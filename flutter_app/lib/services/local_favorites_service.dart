import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesService {
  static const String _plantFavoritesKey = 'favorite_plants';
  static const String _remedyFavoritesKey = 'favorite_remedies';

  // --- Plant Favorites ---

  Future<List<String>> _getPlantFavoritesList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_plantFavoritesKey) ?? [];
  }

  Future<void> _savePlantFavoritesList(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_plantFavoritesKey, favorites);
  }

  Future<List<String>> getPlantFavorites() async {
    return await _getPlantFavoritesList();
  }

  Future<bool> isPlantFavorite(String plantName) async {
    final favorites = await _getPlantFavoritesList();
    return favorites.contains(plantName);
  }

  Future<void> addPlantFavorite(String plantName) async {
    final favorites = await _getPlantFavoritesList();
    if (!favorites.contains(plantName)) {
      favorites.add(plantName);
      await _savePlantFavoritesList(favorites);
    }
  }

  Future<void> removePlantFavorite(String plantName) async {
    final favorites = await _getPlantFavoritesList();
    if (favorites.contains(plantName)) {
      favorites.remove(plantName);
      await _savePlantFavoritesList(favorites);
    }
  }

  // --- Remedy Favorites ---

  Future<List<String>> _getRemedyFavoritesList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_remedyFavoritesKey) ?? [];
  }

  Future<void> _saveRemedyFavoritesList(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_remedyFavoritesKey, favorites);
  }

  Future<List<String>> getRemedyFavorites() async {
    return await _getRemedyFavoritesList();
  }

  // Identifier format: "plantName::remedyTitle"
  String createRemedyIdentifier(String plantName, String remedyTitle) {
    return '$plantName::$remedyTitle';
  }

  // Helper to parse the identifier
  Map<String, String>? parseRemedyIdentifier(String identifier) {
    final parts = identifier.split('::');
    if (parts.length == 2) {
      return {'plantName': parts[0], 'remedyTitle': parts[1]};
    }
    return null;
  }

  Future<bool> isRemedyFavorite(String remedyIdentifier) async {
    final favorites = await _getRemedyFavoritesList();
    return favorites.contains(remedyIdentifier);
  }

  Future<void> addRemedyFavorite(String remedyIdentifier) async {
    final favorites = await _getRemedyFavoritesList();
    if (!favorites.contains(remedyIdentifier)) {
      favorites.add(remedyIdentifier);
      await _saveRemedyFavoritesList(favorites);
    }
  }

  Future<void> removeRemedyFavorite(String remedyIdentifier) async {
    final favorites = await _getRemedyFavoritesList();
    if (favorites.contains(remedyIdentifier)) {
      favorites.remove(remedyIdentifier);
      await _saveRemedyFavoritesList(favorites);
    }
  }
}

