import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'password_hash') required String passwordHash,
    @JsonKey(name: 'password_salt') required String passwordSalt,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
