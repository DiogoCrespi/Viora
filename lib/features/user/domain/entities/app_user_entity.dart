import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user_entity.freezed.dart';
part 'app_user_entity.g.dart';

@freezed
class AppUserEntity with _$AppUserEntity {
  const factory AppUserEntity({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'password_hash') required String passwordHash,
    @JsonKey(name: 'password_salt') required String passwordSalt,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _AppUserEntity;

  factory AppUserEntity.fromJson(Map<String, dynamic> json) =>
      _$AppUserEntityFromJson(json);
}
