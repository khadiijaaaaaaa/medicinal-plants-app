import 'package:flutter/services.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../repositories/plant_repository.dart';
import '../repositories/toxicity_repository.dart';
import '../repositories/medicinal_use_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../repositories/natural_remedy_repository.dart';
import '../models/plant.dart';
import '../models/toxicity.dart';
import '../models/toxicity_effect.dart';
import '../models/medicinal_use.dart';
import '../models/natural_remedy.dart';
import '../models/ingredient.dart';

class DataImporter {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> importInitialData() async {
    final db = await _databaseHelper.database;

    // Check if data already exists
    final count = await db.rawQuery('SELECT COUNT(*) FROM plants');
    if ((count.first.values.first as int) > 0) return;

    // Load JSON file
    final String response = await rootBundle.loadString('assets/plants_data.json');
    final List<dynamic> data = json.decode(response);

    // Import each plant
    for (var plantData in data) {
      await _importPlant(plantData);
    }
  }

  Future<void> _importPlant(Map<String, dynamic> plantData) async {
    final plantRepo = PlantRepository();
    final toxicityRepo = ToxicityRepository();
    final useRepo = MedicinalUseRepository();
    final remedyRepo = NaturalRemedyRepository();
    final ingredientRepo = IngredientRepository(); // Add this line

    // Insert plant
    final plantId = await plantRepo.insertPlant(Plant(
      commonName: plantData['name'],
      scientificName: plantData['scientific_name'],
      origin: plantData['origin'],
      growthEnvironment: plantData['growth_environment'],
      category: plantData['category'],
    ));

    // Insert toxicity info if exists
    if (plantData['toxicity'] != null) {
      final toxicityId = await toxicityRepo.insertToxicity(Toxicity(
        plantId: plantId,
        isToxic: plantData['toxicity']['is_toxic'],
        toxicParts: plantData['toxicity']['toxic_parts'],
      ));

      // Insert toxicity effects
      if (plantData['toxicity']['effects'] != null) {
        for (var effect in plantData['toxicity']['effects']) {
          await toxicityRepo.insertEffect(ToxicityEffect(
            toxicityId: toxicityId,
            effectDescription: effect,
          ));
        }
      }
    }

    // Insert medicinal uses
    if (plantData['medicinal_uses'] != null) {
      for (var use in plantData['medicinal_uses']) {
        await useRepo.insertMedicinalUse(MedicinalUse(
          plantId: plantId,
          useDescription: use,
        ));
      }
    }

    // Insert natural remedies with ingredients
    if (plantData['natural_remedies'] != null) {
      for (var remedyData in plantData['natural_remedies']) {
        final remedyId = await remedyRepo.insertRemedy(NaturalRemedy(
          plantId: plantId,
          title: remedyData['title'],
          instructions: remedyData['instructions'],
          useCategory: remedyData['use_category'],
        ));

        // Insert ingredients - use ingredientRepo instead of remedyRepo
        if (remedyData['ingredients'] != null) {
          for (var ingredient in remedyData['ingredients']) {
            await ingredientRepo.insertIngredient(Ingredient(
              remedyId: remedyId,
              ingredientName: ingredient,
            ));
          }
        }
      }
    }
  }
}