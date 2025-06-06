import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../config/supabase_config.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('UserProvider: Tentando fazer login com email: $email');

      // Primeiro, verifica se o usuário existe no banco de dados
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        debugPrint('UserProvider: Usuário não encontrado no banco de dados');
        return false;
      }

      // Verifica a senha
      final isValid = await _userRepository.verifyPassword(email, password);
      if (!isValid) {
        debugPrint('UserProvider: Senha inválida');
        return false;
      }

      try {
        // Tenta fazer login no Supabase
        debugPrint('UserProvider: Tentando autenticar no Supabase');
        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          debugPrint(
              'UserProvider: Autenticação no Supabase bem-sucedida, ID do usuário: ${response.user?.id}');
          _currentUser = user;
          await _userRepository.updateLastLogin(user.id!);
          notifyListeners();
          return true;
        } else {
          debugPrint('UserProvider: Falha na autenticação no Supabase');
          return false;
        }
      } catch (e) {
        // Se o erro for de email não confirmado
        if (e.toString().contains('email_not_confirmed')) {
          debugPrint('UserProvider: Email não confirmado');
          throw Exception(
              'Por favor, verifique seu email para confirmar sua conta. Se você não recebeu o email, aguarde um minuto antes de tentar novamente.');
        }
        // Se o erro for de credenciais inválidas, tenta criar o usuário no Supabase
        else if (e.toString().contains('invalid_credentials')) {
          debugPrint(
              'UserProvider: Usuário não encontrado no Supabase, tentando criar novo usuário');
          try {
            final signUpResponse = await SupabaseConfig.client.auth.signUp(
              email: email,
              password: password,
              data: {
                'user_id': user.id,
                'name': user.name,
              },
              emailRedirectTo: null, // Desabilita o redirecionamento de email
            );

            if (signUpResponse.user != null) {
              debugPrint(
                  'UserProvider: Usuário criado no Supabase, ID: ${signUpResponse.user?.id}');
              _currentUser = user;
              await _userRepository.updateLastLogin(user.id!);
              notifyListeners();
              throw Exception(
                  'Por favor, verifique seu email para confirmar sua conta. Se você não recebeu o email, aguarde um minuto antes de tentar novamente.');
            }
          } catch (signUpError) {
            if (signUpError.toString().contains('over_email_send_rate_limit')) {
              throw Exception(
                  'Muitas tentativas. Por favor, aguarde um minuto antes de tentar novamente.');
            }
            // Se o erro for que o usuário já existe, tenta fazer login novamente
            if (signUpError.toString().contains('User already registered')) {
              debugPrint(
                  'UserProvider: Usuário já existe no Supabase, tentando login novamente');
              try {
                final loginResponse =
                    await SupabaseConfig.client.auth.signInWithPassword(
                  email: email,
                  password: password,
                );

                if (loginResponse.user != null) {
                  debugPrint(
                      'UserProvider: Login bem-sucedido após nova tentativa');
                  _currentUser = user;
                  await _userRepository.updateLastLogin(user.id!);
                  notifyListeners();
                  return true;
                }
              } catch (retryError) {
                debugPrint(
                    'UserProvider: Erro durante nova tentativa de login: $retryError');
                rethrow;
              }
            }
            rethrow;
          }
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('UserProvider: Erro durante o login: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      debugPrint('UserProvider: Tentando registrar usuário com email: $email');

      // Primeiro, cria o usuário no Supabase Auth com email_confirm desabilitado
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
        emailRedirectTo: null, // Desabilita o redirecionamento de email
      );

      if (response.user != null) {
        debugPrint(
            'UserProvider: Registro no Supabase bem-sucedido, ID do usuário: ${response.user?.id}');

        // Depois, cria o usuário no banco de dados
        final user = await _userRepository.createUser(name, email, password);
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        debugPrint('UserProvider: Falha no registro no Supabase');
        return false;
      }
    } catch (e) {
      debugPrint('UserProvider: Erro durante o registro: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('UserProvider: Attempting logout');
      await SupabaseConfig.client.auth.signOut();
      _currentUser = null;
      notifyListeners();
      debugPrint('UserProvider: Logout successful');
    } catch (e) {
      debugPrint('UserProvider: Error during logout: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatarPath,
  }) async {
    if (_currentUser == null) return false;

    try {
      debugPrint(
          'UserProvider: Updating profile for user: ${_currentUser!.id}');

      await _userRepository.updateUserProfile(
        _currentUser!.id!,
        name: name,
        email: email,
        avatarPath: avatarPath,
      );

      // Update current user
      _currentUser = await _userRepository.getUserByEmail(
        email ?? _currentUser!.email,
      );
      notifyListeners();
      debugPrint('UserProvider: Profile update successful');
      return true;
    } catch (e) {
      debugPrint('UserProvider: Error updating profile: $e');
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      debugPrint('UserProvider: Requesting password reset for email: $email');

      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        debugPrint('UserProvider: User not found for password reset');
        return false;
      }

      // Usa o Supabase para enviar o email de reset
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      debugPrint('UserProvider: Password reset email sent');
      return true;
    } catch (e) {
      debugPrint('UserProvider: Error requesting password reset: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      debugPrint('UserProvider: Resetting password for email: $email');

      // Get user from email
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        debugPrint('UserProvider: User not found for password reset');
        return false;
      }

      // Check if new password is different from current password
      final isCurrentPassword =
          await _userRepository.verifyPassword(email, newPassword);
      if (isCurrentPassword) {
        debugPrint(
            'UserProvider: New password is the same as current password');
        return false;
      }

      // Update password in database
      await _userRepository.updatePassword(user.id!, newPassword);
      debugPrint('UserProvider: Password updated successfully');
      return true;
    } catch (e) {
      debugPrint('UserProvider: Error resetting password: $e');
      return false;
    }
  }
}
