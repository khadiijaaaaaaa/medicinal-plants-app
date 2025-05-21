import '../database/database_helper.dart';
import '../models/toxicity.dart';
import '../models/toxicity_effect.dart';

class ToxicityRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertToxicity(Toxicity toxicity) async {
    final db = await _databaseHelper.database;
    return await db.insert('toxicity', toxicity.toMap());
  }

  Future<Toxicity?> getToxicityByPlantId(int plantId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'toxicity',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Toxicity.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateToxicity(Toxicity toxicity) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'toxicity',
      toxicity.toMap(),
      where: 'toxicity_id = ?',
      whereArgs: [toxicity.toxicityId],
    );
  }

  Future<int> deleteToxicity(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'toxicity',
      where: 'toxicity_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ToxicityEffect>> getEffectsForToxicity(int toxicityId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'toxicity_effects',
      where: 'toxicity_id = ?',
      whereArgs: [toxicityId],
    );
    return List.generate(maps.length, (i) => ToxicityEffect.fromMap(maps[i]));
  }

  Future<int> insertEffect(ToxicityEffect effect) async {
    final db = await _databaseHelper.database;
    return await db.insert('toxicity_effects', effect.toMap());
  }
}