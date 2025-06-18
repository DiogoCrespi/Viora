// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreferencesEntity _$UserPreferencesEntityFromJson(
    Map<String, dynamic> json) {
  return _UserPreferencesEntity.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesEntity {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'theme_mode')
  String? get themeMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'language')
  String? get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'font_size')
  String? get fontSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserPreferencesEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesEntityCopyWith<UserPreferencesEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesEntityCopyWith<$Res> {
  factory $UserPreferencesEntityCopyWith(UserPreferencesEntity value,
          $Res Function(UserPreferencesEntity) then) =
      _$UserPreferencesEntityCopyWithImpl<$Res, UserPreferencesEntity>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'theme_mode') String? themeMode,
      @JsonKey(name: 'language') String? language,
      @JsonKey(name: 'font_size') String? fontSize,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$UserPreferencesEntityCopyWithImpl<$Res,
        $Val extends UserPreferencesEntity>
    implements $UserPreferencesEntityCopyWith<$Res> {
  _$UserPreferencesEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? themeMode = freezed,
    Object? language = freezed,
    Object? fontSize = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: freezed == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesEntityImplCopyWith<$Res>
    implements $UserPreferencesEntityCopyWith<$Res> {
  factory _$$UserPreferencesEntityImplCopyWith(
          _$UserPreferencesEntityImpl value,
          $Res Function(_$UserPreferencesEntityImpl) then) =
      __$$UserPreferencesEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'theme_mode') String? themeMode,
      @JsonKey(name: 'language') String? language,
      @JsonKey(name: 'font_size') String? fontSize,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$UserPreferencesEntityImplCopyWithImpl<$Res>
    extends _$UserPreferencesEntityCopyWithImpl<$Res,
        _$UserPreferencesEntityImpl>
    implements _$$UserPreferencesEntityImplCopyWith<$Res> {
  __$$UserPreferencesEntityImplCopyWithImpl(_$UserPreferencesEntityImpl _value,
      $Res Function(_$UserPreferencesEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? themeMode = freezed,
    Object? language = freezed,
    Object? fontSize = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserPreferencesEntityImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: freezed == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesEntityImpl implements _UserPreferencesEntity {
  const _$UserPreferencesEntityImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'theme_mode') this.themeMode,
      @JsonKey(name: 'language') this.language,
      @JsonKey(name: 'font_size') this.fontSize,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$UserPreferencesEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesEntityImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'theme_mode')
  final String? themeMode;
  @override
  @JsonKey(name: 'language')
  final String? language;
  @override
  @JsonKey(name: 'font_size')
  final String? fontSize;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserPreferencesEntity(userId: $userId, themeMode: $themeMode, language: $language, fontSize: $fontSize, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesEntityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, themeMode, language,
      fontSize, avatarUrl, createdAt, updatedAt);

  /// Create a copy of UserPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesEntityImplCopyWith<_$UserPreferencesEntityImpl>
      get copyWith => __$$UserPreferencesEntityImplCopyWithImpl<
          _$UserPreferencesEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesEntityImplToJson(
      this,
    );
  }
}

abstract class _UserPreferencesEntity implements UserPreferencesEntity {
  const factory _UserPreferencesEntity(
          {@JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'theme_mode') final String? themeMode,
          @JsonKey(name: 'language') final String? language,
          @JsonKey(name: 'font_size') final String? fontSize,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$UserPreferencesEntityImpl;

  factory _UserPreferencesEntity.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesEntityImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'theme_mode')
  String? get themeMode;
  @override
  @JsonKey(name: 'language')
  String? get language;
  @override
  @JsonKey(name: 'font_size')
  String? get fontSize;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesEntityImplCopyWith<_$UserPreferencesEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
