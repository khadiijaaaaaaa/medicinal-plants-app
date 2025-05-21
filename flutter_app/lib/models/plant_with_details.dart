import 'plant.dart';
import 'toxicity.dart';
import 'natural_remedy.dart';

class PlantWithDetails {
  final Plant plant;
  final Toxicity? toxicity;
  final List<String> effects;
  final List<String> medicinalUses;
  final List<NaturalRemedy> remedies;

  PlantWithDetails({
    required this.plant,
    this.toxicity,
    this.effects = const [],
    this.medicinalUses = const [],
    this.remedies = const [],
  });
}