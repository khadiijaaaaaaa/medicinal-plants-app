class ToxicityEffect {
  int? effectId;
  int toxicityId;
  String effectDescription;

  ToxicityEffect({
    this.effectId,
    required this.toxicityId,
    required this.effectDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'effect_id': effectId,
      'toxicity_id': toxicityId,
      'effect_description': effectDescription,
    };
  }

  factory ToxicityEffect.fromMap(Map<String, dynamic> map) {
    return ToxicityEffect(
      effectId: map['effect_id'],
      toxicityId: map['toxicity_id'],
      effectDescription: map['effect_description'],
    );
  }
}