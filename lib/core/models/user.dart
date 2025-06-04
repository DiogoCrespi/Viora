class User {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    this.avatarPath,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['password_hash'],
      passwordSalt: map['password_salt'],
      avatarPath: map['avatar_path'],
      createdAt: DateTime.parse(map['created_at']),
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
      isActive: map['is_active'] == 1,
    );
  }
}
