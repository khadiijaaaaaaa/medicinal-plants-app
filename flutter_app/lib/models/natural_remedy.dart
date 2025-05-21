
import 'ingredient.dart';

class NaturalRemedy {
  int? remedyId;
  int plantId;
  String title;
  String instructions;
  String? useCategory;
  List<Ingredient>? ingredients;

  NaturalRemedy({
    this.remedyId,
    required this.plantId,
    required this.title,
    required this.instructions,
    this.useCategory,
    this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'remedy_id': remedyId,
      'plant_id': plantId,
      'title': title,
      'instructions': instructions,
      'use_category': useCategory,
    };
  }

  factory NaturalRemedy.fromMap(Map<String, dynamic> map) {
    return NaturalRemedy(
      remedyId: map['remedy_id'],
      plantId: map['plant_id'],
      title: map['title'],
      instructions: map['instructions'],
      useCategory: map['use_category'],
    );
  }

  NaturalRemedy copyWith({
    int? remedyId,
    int? plantId,
    String? title,
    String? instructions,
    String? useCategory,
    List<Ingredient>? ingredients,
  }) {
    return NaturalRemedy(
      remedyId: remedyId ?? this.remedyId,
      plantId: plantId ?? this.plantId,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      useCategory: useCategory ?? this.useCategory,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}