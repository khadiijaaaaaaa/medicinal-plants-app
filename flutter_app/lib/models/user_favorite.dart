class UserFavorite {
  int? favoriteId;
  int userId;
  int plantId;
  String? createdAt;

  UserFavorite({
    this.favoriteId,
    required this.userId,
    required this.plantId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'favorite_id': favoriteId,
      'user_id': userId,
      'plant_id': plantId,
      'created_at': createdAt,
    };
  }

  factory UserFavorite.fromMap(Map<String, dynamic> map) {
    return UserFavorite(
      favoriteId: map['favorite_id'],
      userId: map['user_id'],
      plantId: map['plant_id'],
      createdAt: map['created_at'],
    );
  }
}