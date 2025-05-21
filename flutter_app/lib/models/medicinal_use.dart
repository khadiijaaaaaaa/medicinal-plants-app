class MedicinalUse {
  int? useId;
  int plantId;
  String useDescription;

  MedicinalUse({
    this.useId,
    required this.plantId,
    required this.useDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'use_id': useId,
      'plant_id': plantId,
      'use_description': useDescription,
    };
  }

  factory MedicinalUse.fromMap(Map<String, dynamic> map) {
    return MedicinalUse(
      useId: map['use_id'],
      plantId: map['plant_id'],
      useDescription: map['use_description'],
    );
  }
}