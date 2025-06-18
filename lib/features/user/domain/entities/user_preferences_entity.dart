import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences_entity.freezed.dart';
part 'user_preferences_entity.g.dart';

@freezed
class UserPreferencesEntity with _$UserPreferencesEntity {
  const factory UserPreferencesEntity({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'theme_mode') String? themeMode,
    @JsonKey(name: 'language') String? language,
    @JsonKey(name: 'font_size') String? fontSize,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserPreferencesEntity;

  factory UserPreferencesEntity.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesEntityFromJson(json);
}
