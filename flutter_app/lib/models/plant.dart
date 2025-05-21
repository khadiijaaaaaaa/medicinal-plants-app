class Plant {
  int? plantId;
  String commonName;
  String scientificName;
  String? origin;
  String? growthEnvironment;
  String? category;
  String? imagePath;
  bool isFavorite;
  String? lastViewed;
  String? createdAt;

  Plant({
    this.plantId,
    required this.commonName,
    required this.scientificName,
    this.origin,
    this.growthEnvironment,
    this.category,
    this.imagePath,
    this.isFavorite = false,
    this.lastViewed,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'plant_id': plantId,
      'common_name': commonName,
      'scientific_name': scientificName,
      'origin': origin,
      'growth_environment': growthEnvironment,
      'category': category,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'last_viewed': lastViewed,
      'created_at': createdAt,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      plantId: map['plant_id'],
      commonName: map['common_name'],
      scientificName: map['scientific_name'],
      origin: map['origin'],
      growthEnvironment: map['growth_environment'],
      category: map['category'],
      imagePath: map['image_path'],
      isFavorite: map['is_favorite'] == 1,
      lastViewed: map['last_viewed'],
      createdAt: map['created_at'],
    );
  }
}