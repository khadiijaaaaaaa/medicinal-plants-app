import '../database/database_helper.dart';
import '../models/medicinal_use.dart';

class MedicinalUseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertMedicinalUse(MedicinalUse use) async {
    final db = await _databaseHelper.database;
    return await db.insert('medicinal_uses', use.toMap());
  }

  Future<List<MedicinalUse>> getUsesForPlant(int plantId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicinal_uses',
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );
    return List.generate(maps.length, (i) => MedicinalUse.fromMap(maps[i]));
  }

  Future<int> updateMedicinalUse(MedicinalUse use) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'medicinal_uses',
      use.toMap(),
      where: 'use_id = ?',
      whereArgs: [use.useId],
    );
  }

  Future<int> deleteMedicinalUse(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'medicinal_uses',
      where: 'use_id = ?',
      whereArgs: [id],
    );
  }
}