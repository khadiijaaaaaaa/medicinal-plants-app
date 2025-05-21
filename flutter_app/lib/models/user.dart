class User {
  int? userId;
  String email;
  String passwordHash;
  String? createdAt;

  User({
    this.userId,
    required this.email,
    required this.passwordHash,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      createdAt: map['created_at'],
    );
  }
}