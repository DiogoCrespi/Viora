// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUserEntity _$AppUserEntityFromJson(Map<String, dynamic> json) {
  return _AppUserEntity.fromJson(json);
}

/// @nodoc
mixin _$AppUserEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'password_hash')
  String get passwordHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'password_salt')
  String get passwordSalt => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_path')
  String? get avatarPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this AppUserEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserEntityCopyWith<AppUserEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserEntityCopyWith<$Res> {
  factory $AppUserEntityCopyWith(
          AppUserEntity value, $Res Function(AppUserEntity) then) =
      _$AppUserEntityCopyWithImpl<$Res, AppUserEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      @JsonKey(name: 'password_hash') String passwordHash,
      @JsonKey(name: 'password_salt') String passwordSalt,
      @JsonKey(name: 'avatar_path') String? avatarPath,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'last_login') DateTime? lastLogin,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$AppUserEntityCopyWithImpl<$Res, $Val extends AppUserEntity>
    implements $AppUserEntityCopyWith<$Res> {
  _$AppUserEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? passwordHash = null,
    Object? passwordSalt = null,
    Object? avatarPath = freezed,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      passwordHash: null == passwordHash
          ? _value.passwordHash
          : passwordHash // ignore: cast_nullable_to_non_nullable
              as String,
      passwordSalt: null == passwordSalt
          ? _value.passwordSalt
          : passwordSalt // ignore: cast_nullable_to_non_nullable
              as String,
      avatarPath: freezed == avatarPath
          ? _value.avatarPath
          : avatarPath // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserEntityImplCopyWith<$Res>
    implements $AppUserEntityCopyWith<$Res> {
  factory _$$AppUserEntityImplCopyWith(
          _$AppUserEntityImpl value, $Res Function(_$AppUserEntityImpl) then) =
      __$$AppUserEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      @JsonKey(name: 'password_hash') String passwordHash,
      @JsonKey(name: 'password_salt') String passwordSalt,
      @JsonKey(name: 'avatar_path') String? avatarPath,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'last_login') DateTime? lastLogin,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$AppUserEntityImplCopyWithImpl<$Res>
    extends _$AppUserEntityCopyWithImpl<$Res, _$AppUserEntityImpl>
    implements _$$AppUserEntityImplCopyWith<$Res> {
  __$$AppUserEntityImplCopyWithImpl(
      _$AppUserEntityImpl _value, $Res Function(_$AppUserEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? passwordHash = null,
    Object? passwordSalt = null,
    Object? avatarPath = freezed,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? isActive = null,
  }) {
    return _then(_$AppUserEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      passwordHash: null == passwordHash
          ? _value.passwordHash
          : passwordHash // ignore: cast_nullable_to_non_nullable
              as String,
      passwordSalt: null == passwordSalt
          ? _value.passwordSalt
          : passwordSalt // ignore: cast_nullable_to_non_nullable
              as String,
      avatarPath: freezed == avatarPath
          ? _value.avatarPath
          : avatarPath // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserEntityImpl implements _AppUserEntity {
  const _$AppUserEntityImpl(
      {required this.id,
      required this.name,
      required this.email,
      @JsonKey(name: 'password_hash') required this.passwordHash,
      @JsonKey(name: 'password_salt') required this.passwordSalt,
      @JsonKey(name: 'avatar_path') this.avatarPath,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'last_login') this.lastLogin,
      @JsonKey(name: 'is_active') this.isActive = true});

  factory _$AppUserEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  @JsonKey(name: 'password_hash')
  final String passwordHash;
  @override
  @JsonKey(name: 'password_salt')
  final String passwordSalt;
  @override
  @JsonKey(name: 'avatar_path')
  final String? avatarPath;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'AppUserEntity(id: $id, name: $name, email: $email, passwordHash: $passwordHash, passwordSalt: $passwordSalt, avatarPath: $avatarPath, createdAt: $createdAt, lastLogin: $lastLogin, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.passwordHash, passwordHash) ||
                other.passwordHash == passwordHash) &&
            (identical(other.passwordSalt, passwordSalt) ||
                other.passwordSalt == passwordSalt) &&
            (identical(other.avatarPath, avatarPath) ||
                other.avatarPath == avatarPath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, passwordHash,
      passwordSalt, avatarPath, createdAt, lastLogin, isActive);

  /// Create a copy of AppUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserEntityImplCopyWith<_$AppUserEntityImpl> get copyWith =>
      __$$AppUserEntityImplCopyWithImpl<_$AppUserEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserEntityImplToJson(
      this,
    );
  }
}

abstract class _AppUserEntity implements AppUserEntity {
  const factory _AppUserEntity(
      {required final String id,
      required final String name,
      required final String email,
      @JsonKey(name: 'password_hash') required final String passwordHash,
      @JsonKey(name: 'password_salt') required final String passwordSalt,
      @JsonKey(name: 'avatar_path') final String? avatarPath,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'last_login') final DateTime? lastLogin,
      @JsonKey(name: 'is_active') final bool isActive}) = _$AppUserEntityImpl;

  factory _AppUserEntity.fromJson(Map<String, dynamic> json) =
      _$AppUserEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  @JsonKey(name: 'password_hash')
  String get passwordHash;
  @override
  @JsonKey(name: 'password_salt')
  String get passwordSalt;
  @override
  @JsonKey(name: 'avatar_path')
  String? get avatarPath;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of AppUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserEntityImplCopyWith<_$AppUserEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
