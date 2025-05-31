class User {
  int? userId;
  String email;
  String passwordHash;
  String? name;
  String? profileImagePath;
  String? createdAt;

  User({
    this.userId,
    required this.email,
    required this.passwordHash,
    this.name,
    this.profileImagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'password_hash': passwordHash,
      'name': name,
      'profile_image_path': profileImagePath,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      name: map['name'],
      profileImagePath: map['profile_image_path'],
      createdAt: map['created_at'],
    );
  }
}