import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_response.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  Future<CustomAuthResponse> register(
      String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // Verifica se o email precisa ser confirmado
        if (response.session == null) {
          return CustomAuthResponse(
            success: false,
            error: 'registerErrorEmailConfirmationRequired',
            user: response.user,
          );
        }

        // Cria o perfil do usuário no banco de dados
        await _createUserProfile(response.user!.id, name, email);

        return CustomAuthResponse(
          success: true,
          user: response.user,
          session: response.session,
        );
      } else {
        return CustomAuthResponse(
          success: false,
          error: 'registerErrorUnknown',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: register: Error during registration: $e');
      }
      return CustomAuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _insertUserProfile(
      String userId, String name, String email) async {
    try {
      await _supabase.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'password_hash': '', // Não armazenamos a senha em texto plano
        'password_salt': '', // Não armazenamos o salt em texto plano
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserProfile: User profile inserted for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserProfile: Error inserting user profile for $userId: $e');
      }
      rethrow; // Rethrow to allow _createUserProfile to handle overall failure
    }
  }

  Future<void> _insertUserSettings(String userId) async {
    try {
      await _supabase.from('user_settings').insert({
        'user_id': userId,
        'language_code': 'pt', // Default language
        'theme_mode': 'system', // Default theme
        'font_size': 1.0, // Default font size scale
        'notifications_enabled': true, // Default notification setting
      });
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserSettings: User settings inserted for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserSettings: Error inserting user settings for $userId: $e');
      }
      rethrow;
    }
  }

  Future<void> _insertUserPreferences(String userId) async {
    try {
      await _supabase.from('user_preferences').insert({
        'user_id': userId,
        'theme_mode': 'system',
        'language': 'pt',
        'font_size': 'medium',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserPreferences: User preferences inserted for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _insertUserPreferences: Error inserting user preferences for $userId: $e');
      }
      rethrow;
    }
  }

  Future<void> _insertGameProgress(String userId) async {
    try {
      await _supabase.from('game_progress').insert({
        'user_id': userId,
        'level': 1,
        'experience': 0,
        'max_score': 0,
        'missions_completed': 0,
        // 'last_played' can be omitted or set to NOW() if your DB supports it
      });
      if (kDebugMode) {
        debugPrint('AuthService: _insertGameProgress: Game progress inserted for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _insertGameProgress: Error inserting game progress for $userId: $e');
      }
      rethrow;
    }
  }

  Future<void> _createUserProfile(
      String userId, String name, String email) async {
    try {
      await _insertUserProfile(userId, name, email);
      await _insertUserSettings(userId);
      await _insertUserPreferences(userId);
      await _insertGameProgress(userId);
      await _initializeUserMissions(userId);
      if (kDebugMode) {
        debugPrint('AuthService: _createUserProfile: Successfully created complete user profile for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _createUserProfile: Error during the overall user profile creation process for $userId: $e');
      }
      // Depending on the desired behavior, you might want to implement
      // rollback logic here if any step fails. For now, just rethrowing.
      rethrow;
    }
  }

  Future<void> _initializeUserMissions(String userId) async {
    try {
      // Busca todas as missões disponíveis
      final missions = await _supabase.from('missions').select();

      // Insere as missões para o usuário
      final userMissions = missions.map((mission) => {
            'user_id': userId,
            'mission_id': mission['id'],
            'status': 'locked', // Default status for new users
            'updated_at': DateTime.now().toIso8601String(),
          }).toList();

      if (userMissions.isNotEmpty) {
        await _supabase.from('user_missions').insert(userMissions);
      }
      if (kDebugMode) {
        debugPrint('AuthService: _initializeUserMissions: User missions initialized for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: _initializeUserMissions: Error initializing user missions for $userId: $e');
      }
      // Not rethrowing here as this might be considered a non-critical part of profile creation
      // or could have its own retry/recovery logic.
    }
  }
}
