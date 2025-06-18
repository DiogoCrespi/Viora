// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesEntityImpl _$$UserPreferencesEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesEntityImpl(
      userId: json['user_id'] as String,
      themeMode: json['theme_mode'] as String?,
      language: json['language'] as String?,
      fontSize: json['font_size'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserPreferencesEntityImplToJson(
        _$UserPreferencesEntityImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'theme_mode': instance.themeMode,
      'language': instance.language,
      'font_size': instance.fontSize,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
