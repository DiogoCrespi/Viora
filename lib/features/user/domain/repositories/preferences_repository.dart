import 'package:viora/features/user/domain/entities/user_preferences_entity.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:flutter/foundation.dart';

class PreferencesRepository {
  final _supabase = SupabaseConfig.client;

  Future<UserPreferencesEntity> getUserPreferences(String userId) async {
    try {
      debugPrint(
          'PreferencesRepository: Fetching preferences for user: $userId');
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      debugPrint('PreferencesRepository: Raw response: $response');
      return UserPreferencesEntity.fromJson(response);
    } catch (e) {
      debugPrint('PreferencesRepository: Error fetching preferences: $e');
      // Se não encontrar preferências, cria um novo registro com valores padrão
      final now = DateTime.now().toIso8601String();
      final defaultData = {
        'user_id': userId,
        'theme_mode': 'system',
        'language': 'pt',
        'font_size': 'medium',
        'avatar_url': null,
        'created_at': now,
        'updated_at': now,
      };

      debugPrint('PreferencesRepository: Creating default preferences');
      final response = await _supabase
          .from('user_preferences')
          .insert(defaultData)
          .select()
          .single();

      debugPrint('PreferencesRepository: Created preferences: $response');
      return UserPreferencesEntity.fromJson(response);
    }
  }

  Future<void> updateUserPreferences(UserPreferencesEntity preferences) async {
    final data = {
      'theme_mode': preferences.themeMode,
      'language': preferences.language,
      'font_size': preferences.fontSize,
      'avatar_url': preferences.avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('user_preferences')
        .update(data)
        .eq('user_id', preferences.userId);
  }

  Future<void> updateThemeMode(String userId, String themeMode) async {
    await _supabase.from('user_preferences').update({
      'theme_mode': themeMode,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('user_id', userId);
  }

  Future<void> updateLanguage(String userId, String language) async {
    await _supabase.from('user_preferences').update({
      'language': language,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('user_id', userId);
  }

  Future<void> updateFontSize(String userId, String fontSize) async {
    await _supabase.from('user_preferences').update({
      'font_size': fontSize,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('user_id', userId);
  }

  Future<void> updateAvatarUrl(String userId, String avatarUrl) async {
    await _supabase.from('user_preferences').update({
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('user_id', userId);
  }
}
