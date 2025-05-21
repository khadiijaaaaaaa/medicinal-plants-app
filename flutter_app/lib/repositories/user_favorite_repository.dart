import '../database/database_helper.dart';
import '../models/user_favorite.dart';

class UserFavoriteRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> addFavorite(UserFavorite favorite) async {
    final db = await _databaseHelper.database;
    return await db.insert('user_favorites', favorite.toMap());
  }

  Future<List<UserFavorite>> getFavoritesForUser(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => UserFavorite.fromMap(maps[i]));
  }

  Future<bool> isPlantFavorite(int userId, int plantId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_favorites',
      where: 'user_id = ? AND plant_id = ?',
      whereArgs: [userId, plantId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> removeFavorite(int userId, int plantId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'user_favorites',
      where: 'user_id = ? AND plant_id = ?',
      whereArgs: [userId, plantId],
    );
  }
}