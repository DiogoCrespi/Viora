import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('UserProvider: Tentando fazer login com email: $email');

      // Primeiro tenta fazer login no Supabase
      try {
        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Verifica se o email está confirmado
          if (response.user?.emailConfirmedAt == null) {
            debugPrint('UserProvider: Email não confirmado');
            throw Exception('loginErrorEmailNotConfirmed');
          }

          debugPrint('UserProvider: Autenticação no Supabase bem-sucedida');
          
          // Verifica se o usuário existe no SQLite
          var user = await _userRepository.getUserByEmail(email);
          if (user == null) {
            // Se não existe no SQLite, cria o usuário
            debugPrint('UserProvider: Criando usuário no SQLite');
            user = await _userRepository.createUser(
              response.user!.userMetadata?['name'] ?? email.split('@')[0],
              email,
              password,
              response.user!.id,
            );
          }

          _currentUser = user;
          if (user?.id != null) {
            await _userRepository.updateLastLogin(user!.id!);
          }
          notifyListeners();
          return true;
        }
      } catch (e) {
        if (e.toString().contains('email_not_confirmed') || 
            e.toString().contains('loginErrorEmailNotConfirmed')) {
          debugPrint('UserProvider: Email não confirmado');
          throw Exception('loginErrorEmailNotConfirmed');
        }
        rethrow;
      }

      debugPrint('UserProvider: Falha na autenticação');
      return false;
    } catch (e) {
      debugPrint('UserProvider: Erro durante o login: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      debugPrint('UserProvider: Tentando registrar usuário com email: $email');

      // Validação mais rigorosa do email
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        debugPrint('UserProvider: Email inválido');
        throw Exception('registerErrorInvalidEmail');
      }

      // Primeiro, verifica se o usuário já existe no Supabase Auth
      try {
        final authResponse = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (authResponse.user != null) {
          debugPrint('UserProvider: Usuário já existe no Supabase Auth');
          // Verifica se o usuário existe no SQLite
          final localUser = await _userRepository.getUserByEmail(email);
          if (localUser == null) {
            // Se não existe no SQLite, cria o usuário local
            debugPrint('UserProvider: Criando usuário no SQLite');
            final user = await _userRepository.createUser(
              name,
              email,
              password,
              authResponse.user!.id,
            );
            _currentUser = user;
            notifyListeners();
            return true;
          }
          throw Exception('registerErrorEmailInUse');
        }
      } catch (e) {
        // Se o erro for de credenciais inválidas, significa que o usuário não existe
        if (!e.toString().contains('Invalid login credentials')) {
          if (e.toString().contains('email_address_invalid')) {
            throw Exception('registerErrorInvalidEmail');
          }
          // Se o erro for de email em uso, verifica se é um usuário não confirmado
          if (e.toString().contains('Email not confirmed')) {
            debugPrint('UserProvider: Email não confirmado, tentando reenviar confirmação');
            try {
              await SupabaseConfig.client.auth.resend(
                type: supabase.OtpType.signup,
                email: email,
              );
              throw Exception('registerErrorEmailConfirmationRequired');
            } catch (resendError) {
              debugPrint('UserProvider: Erro ao reenviar confirmação: $resendError');
              throw Exception('registerErrorEmailConfirmationRequired');
            }
          }
          rethrow;
        }
      }

      // Cria o usuário no Supabase Auth
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'email_confirm': true,
        },
        emailRedirectTo: 'io.supabase.viora://login-callback/',
      );

      if (authResponse.user == null) {
        debugPrint('UserProvider: Falha no registro no Supabase Auth');
        return false;
      }

      debugPrint('UserProvider: Registro no Supabase Auth bem-sucedido');

      // Verifica se o email precisa ser confirmado
      if (authResponse.user?.emailConfirmedAt == null) {
        debugPrint('UserProvider: Email precisa ser confirmado');
        debugPrint('UserProvider: Email de confirmação já foi enviado automaticamente');
        throw Exception('registerErrorEmailConfirmationRequired');
      }

      // Cria o usuário na tabela users do SQLite
      final user = await _userRepository.createUser(
        name,
        email,
        password,
        authResponse.user!.id,
      );

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('UserProvider: Erro durante o registro: $e');
      if (e.toString().contains('registerErrorEmailInUse')) {
        throw Exception('registerErrorEmailInUse');
      }
      if (e.toString().contains('email_not_confirmed') || 
          e.toString().contains('registerErrorEmailConfirmationRequired')) {
        throw Exception('registerErrorEmailConfirmationRequired');
      }
      if (e.toString().contains('email_address_invalid') ||
          e.toString().contains('registerErrorInvalidEmail')) {
        throw Exception('registerErrorInvalidEmail');
      }
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

  // Adicionar novo método para reenviar email de confirmação
  Future<bool> resendConfirmationEmail(String email) async {
    try {
      debugPrint('UserProvider: Tentando reenviar email de confirmação para: $email');
      await SupabaseConfig.client.auth.resend(
        type: supabase.OtpType.signup,
        email: email,
      );
      debugPrint('UserProvider: Email de confirmação reenviado com sucesso');
      return true;
    } catch (e) {
      debugPrint('UserProvider: Erro ao reenviar email de confirmação: $e');
      if (e.toString().contains('over_email_send_rate_limit')) {
        throw Exception('loginErrorResendingConfirmation');
      }
      rethrow;
    }
  }
}
