// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserEntityImpl _$$AppUserEntityImplFromJson(Map<String, dynamic> json) =>
    _$AppUserEntityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      passwordSalt: json['password_salt'] as String,
      avatarPath: json['avatar_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$AppUserEntityImplToJson(_$AppUserEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password_hash': instance.passwordHash,
      'password_salt': instance.passwordSalt,
      'avatar_path': instance.avatarPath,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login': instance.lastLogin?.toIso8601String(),
      'is_active': instance.isActive,
    };
