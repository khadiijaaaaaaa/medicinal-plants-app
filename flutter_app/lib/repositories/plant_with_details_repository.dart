import '../database/database_helper.dart';
import '../models/plant_with_details.dart';
import '../models/plant.dart';
import '../models/toxicity.dart';
import '../models/natural_remedy.dart';
import '../models/ingredient.dart';

class PlantWithDetailsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<PlantWithDetails?> getPlantWithDetails(int plantId) async {
    final db = await _databaseHelper.database;

    // Get plant
    final plantMaps = await db.query(
      'plants',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      limit: 1,
    );

    if (plantMaps.isEmpty) return null;

    final plant = Plant.fromMap(plantMaps.first);

    // Get toxicity info
    final toxicityMaps = await db.query(
      'toxicity',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      limit: 1,
    );

    Toxicity? toxicity;
    List<String> effects = [];

    if (toxicityMaps.isNotEmpty) {
      toxicity = Toxicity.fromMap(toxicityMaps.first);

      // Get toxicity effects
      final effectMaps = await db.query(
        'toxicity_effects',
        where: 'toxicity_id = ?',
        whereArgs: [toxicity.toxicityId],
      );

      effects = effectMaps.map((e) => e['effect_description'] as String).toList();
    }

    // Get medicinal uses
    final useMaps = await db.query(
      'medicinal_uses',
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );

    final uses = useMaps.map((e) => e['use_description'] as String).toList();

    // Get remedies with ingredients
    final remedyMaps = await db.query(
      'natural_remedies',
      where: 'plant_id = ?',
      whereArgs: [plantId],
    );

    final remedies = await Future.wait(remedyMaps.map((remedyMap) async {
      final remedy = NaturalRemedy.fromMap(remedyMap);

      // Get ingredients for this remedy
      final ingredientMaps = await db.query(
        'remedy_ingredients',
        where: 'remedy_id = ?',
        whereArgs: [remedy.remedyId],
      );

      final ingredients = ingredientMaps.map((e) =>
          Ingredient.fromMap(e)).toList();

      return remedy.copyWith(ingredients: ingredients);
    }));

    return PlantWithDetails(
      plant: plant,
      toxicity: toxicity,
      effects: effects,
      medicinalUses: uses,
      remedies: remedies,
    );
  }
}