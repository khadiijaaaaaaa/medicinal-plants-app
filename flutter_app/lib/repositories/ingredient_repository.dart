import '../database/database_helper.dart';
import '../models/ingredient.dart';

class IngredientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await _databaseHelper.database;
    return await db.insert('remedy_ingredients', ingredient.toMap());
  }

  Future<List<Ingredient>> getIngredientsForRemedy(int remedyId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'remedy_ingredients',
      where: 'remedy_id = ?',
      whereArgs: [remedyId],
    );
    return List.generate(maps.length, (i) => Ingredient.fromMap(maps[i]));
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'remedy_ingredients',
      ingredient.toMap(),
      where: 'ingredient_id = ?',
      whereArgs: [ingredient.ingredientId],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'remedy_ingredients',
      where: 'ingredient_id = ?',
      whereArgs: [id],
    );
  }
}