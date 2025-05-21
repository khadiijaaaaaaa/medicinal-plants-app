import '../database/database_helper.dart';
import '../models/natural_remedy.dart';
import '../models/ingredient.dart';

class NaturalRemedyRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertRemedy(NaturalRemedy remedy) async {
    final db = await _databaseHelper.database;
    return await db.insert('natural_remedies', remedy.toMap());
  }

  Future<List<NaturalRemedy>> getRemediesForPlant(int plantId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'natural_remedies',
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );
    return List.generate(maps.length, (i) => NaturalRemedy.fromMap(maps[i]));
  }

  Future<NaturalRemedy?> getRemedyWithIngredients(int remedyId) async {
    final db = await _databaseHelper.database;

    // Get the remedy
    final remedyMaps = await db.query(
      'natural_remedies',
      where: 'remedy_id = ?',
      whereArgs: [remedyId],
      limit: 1,
    );

    if (remedyMaps.isEmpty) return null;

    final remedy = NaturalRemedy.fromMap(remedyMaps.first);

    // Get ingredients
    final ingredientMaps = await db.query(
      'remedy_ingredients',
      where: 'remedy_id = ?',
      whereArgs: [remedyId],
    );

    final ingredients = List.generate(
        ingredientMaps.length,
            (i) => Ingredient.fromMap(ingredientMaps[i])
    );

    return remedy.copyWith(ingredients: ingredients);
  }

  Future<int> updateRemedy(NaturalRemedy remedy) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'natural_remedies',
      remedy.toMap(),
      where: 'remedy_id = ?',
      whereArgs: [remedy.remedyId],
    );
  }

  Future<int> deleteRemedy(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'natural_remedies',
      where: 'remedy_id = ?',
      whereArgs: [id],
    );
  }
}