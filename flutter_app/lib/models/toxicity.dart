class Toxicity {
  int? toxicityId;
  int plantId;
  bool isToxic;
  String? toxicParts;

  Toxicity({
    this.toxicityId,
    required this.plantId,
    required this.isToxic,
    this.toxicParts,
  });

  Map<String, dynamic> toMap() {
    return {
      'toxicity_id': toxicityId,
      'plant_id': plantId,
      'is_toxic': isToxic ? 1 : 0,
      'toxic_parts': toxicParts,
    };
  }

  factory Toxicity.fromMap(Map<String, dynamic> map) {
    return Toxicity(
      toxicityId: map['toxicity_id'],
      plantId: map['plant_id'],
      isToxic: map['is_toxic'] == 1,
      toxicParts: map['toxic_parts'],
    );
  }
}