import '../database/database_helper.dart';
import '../models/plant.dart';

class PlantRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertPlant(Plant plant) async {
    final db = await _databaseHelper.database;
    return await db.insert('plants', plant.toMap());
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('plants');
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  Future<Plant?> getPlantById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'plant_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Plant.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'plants',
      plant.toMap(),
      where: 'plant_id = ?',
      whereArgs: [plant.plantId],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'plants',
      where: 'plant_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Plant>> searchPlants(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'common_name LIKE ? OR scientific_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(int plantId, bool isFavorite) async {
    final db = await _databaseHelper.database;
    await db.update(
      'plants',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );
  }
}
