import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_preferences.dart';
import '../config/supabase_config.dart';

class PreferencesRepository {
  final _supabase = SupabaseConfig.client;

  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      return UserPreferences.fromJson(response);
    } catch (e) {
      // Se não encontrar preferências, cria um novo registro com valores padrão
      final defaultPreferences = UserPreferences(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase
          .from('user_preferences')
          .insert(defaultPreferences.toJson());
      return defaultPreferences;
    }
  }

  Future<void> updateUserPreferences(UserPreferences preferences) async {
    await _supabase
        .from('user_preferences')
        .update(preferences.toJson())
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
