import '../database/database_helper.dart';
import '../models/identification_history.dart';

class IdentificationHistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> addHistoryRecord(IdentificationHistory history) async {
    final db = await _databaseHelper.database;
    return await db.insert('identification_history', history.toMap());
  }

  Future<List<IdentificationHistory>> getHistoryForUser(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'identification_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'identification_date DESC',
    );
    return List.generate(maps.length, (i) => IdentificationHistory.fromMap(maps[i]));
  }

  Future<List<IdentificationHistory>> getRecentHistory(int limit) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'identification_history',
      orderBy: 'identification_date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => IdentificationHistory.fromMap(maps[i]));
  }

  Future<int> clearHistoryForUser(int userId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'identification_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}