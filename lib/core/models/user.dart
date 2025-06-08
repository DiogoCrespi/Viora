import 'package:freezed_annotation/freezed_annotation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String? avatarPath;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'last_login')
  final String? lastLogin;
  @JsonKey(name: 'is_active')
  final int isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    this.avatarPath,
    required this.createdAt,
    this.lastLogin,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'avatar_path': avatarPath,
      'created_at': createdAt,
      'last_login': lastLogin,
      'is_active': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      passwordSalt: json['password_salt'] as String,
      avatarPath: json['avatar_path'] as String?,
      createdAt: json['created_at'] is DateTime 
          ? (json['created_at'] as DateTime).toIso8601String()
          : json['created_at'] as String,
      lastLogin: json['last_login'] != null 
          ? (json['last_login'] is DateTime 
              ? (json['last_login'] as DateTime).toIso8601String()
              : json['last_login'] as String)
          : null,
      isActive: json['is_active'] is bool 
          ? (json['is_active'] as bool ? 1 : 0)
          : json['is_active'] as int,
    );
  }

  static String dateTimeToIso8601(DateTime dateTime) => dateTime.toIso8601String();

  static DateTime? iso8601ToDateTime(String? dateStr) => 
      dateStr != null ? DateTime.parse(dateStr) : null;

  static int boolToInt(bool value) => value ? 1 : 0;

  static bool intToBool(int value) => value == 1;
}
