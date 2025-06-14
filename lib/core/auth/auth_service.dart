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
      print('Erro durante o registro: $e');
      return CustomAuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _createUserProfile(
      String userId, String name, String email) async {
    try {
      // Cria o perfil do usuário
      await _supabase.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'password_hash': '', // Não armazenamos a senha em texto plano
        'password_salt': '', // Não armazenamos o salt em texto plano
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      // Cria as configurações do usuário
      await _supabase.from('user_settings').insert({
        'user_id': userId,
        'language_code': 'pt',
        'theme_mode': 'system',
        'font_size': 1.0,
        'notifications_enabled': true,
      });

      // Cria as preferências do usuário
      await _supabase.from('user_preferences').insert({
        'user_id': userId,
        'theme_mode': 'system',
        'language': 'pt',
        'font_size': 'medium',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Cria o progresso do jogo
      await _supabase.from('game_progress').insert({
        'user_id': userId,
        'level': 1,
        'experience': 0,
        'max_score': 0,
        'missions_completed': 0,
      });

      // Inicializa as missões do usuário
      await _initializeUserMissions(userId);
    } catch (e) {
      print('Erro ao criar perfil do usuário: $e');
      rethrow;
    }
  }

  Future<void> _initializeUserMissions(String userId) async {
    try {
      // Busca todas as missões disponíveis
      final missions = await _supabase.from('missions').select();

      // Insere as missões para o usuário
      for (var mission in missions) {
        await _supabase.from('user_missions').insert({
          'user_id': userId,
          'mission_id': mission['id'],
          'status': 'locked',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erro ao inicializar missões do usuário: $e');
    }
  }
}
