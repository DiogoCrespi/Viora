import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    String? id,
    required String name,
    required String email,
    @JsonKey(name: 'password_hash') required String passwordHash,
    @JsonKey(name: 'password_salt') required String passwordSalt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
