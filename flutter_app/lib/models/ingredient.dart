class Ingredient {
  int? ingredientId;
  int remedyId;
  String ingredientName;
  String? quantity;

  Ingredient({
    this.ingredientId,
    required this.remedyId,
    required this.ingredientName,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredient_id': ingredientId,
      'remedy_id': remedyId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientId: map['ingredient_id'],
      remedyId: map['remedy_id'],
      ingredientName: map['ingredient_name'],
      quantity: map['quantity'],
    );
  }
}