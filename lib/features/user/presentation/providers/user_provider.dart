import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/features/user/domain/repositories/user_repository.dart';
import 'package:viora/features/user/domain/entities/app_user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final IUserRepository _userRepository;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastPasswordResetRequest;

  UserProvider([Database? db])
      : _userRepository =
            UserRepositoryFactory.create(SupabaseConfig.client, db);

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('UserProvider: Tentando fazer login com email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      debugPrint('UserProvider: Autenticação no Supabase bem-sucedida');
      debugPrint('UserProvider: Session: ${response.session?.user.id}');
      debugPrint('UserProvider: User: ${response.user?.id}');

      // Buscar ou criar usuário no repositório
      var user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        // Se o usuário não existe no repositório, criar um novo
        user = await _userRepository.createUser(
          AppUser(
            id: response.user!.id,
            name: response.user!.userMetadata?['name'] ?? email.split('@')[0],
            email: email,
            passwordHash: '', // Não armazenamos senha localmente
            passwordSalt: '', // Não armazenamos salt localmente
            createdAt: DateTime.now(),
          ),
        );
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider: Erro durante login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String? avatarPath) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');

      final updatedUser = _currentUser!.copyWith(
        name: name,
        avatarPath: avatarPath,
      );

      await _userRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      debugPrint('UserProvider: Tentando registrar usuário com email: $email');

      // Validação mais rigorosa do email
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email)) {
        debugPrint('UserProvider: Email inválido');
        throw Exception('registerErrorInvalidEmail');
      }

      // Verifica se o usuário já existe no Supabase Auth
      try {
        final response = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('email', email);

        if (response.isNotEmpty) {
          debugPrint('UserProvider: Usuário já existe no Supabase Auth');
          throw Exception('registerErrorEmailInUse');
        }
      } catch (e) {
        if (e.toString().contains('email_address_invalid')) {
          throw Exception('registerErrorInvalidEmail');
        }
        rethrow;
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
        debugPrint(
            'UserProvider: Email de confirmação já foi enviado automaticamente');
        throw Exception('registerErrorEmailConfirmationRequired');
      }

      // Cria o usuário na tabela users do Supabase
      final user = await _userRepository.createUser(
        AppUser(
          id: authResponse.user!.id,
          name: name,
          email: email,
          passwordHash: '', // Empty for Supabase auth
          passwordSalt: '', // Empty for Supabase auth
          createdAt: DateTime.now(),
        ),
      );

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('UserProvider: Erro durante o registro: $e');
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      // Verificar se já fez uma requisição recente (dentro de 1 minuto)
      if (_lastPasswordResetRequest != null) {
        final timeSinceLastRequest =
            DateTime.now().difference(_lastPasswordResetRequest!);
        if (timeSinceLastRequest.inMinutes < 1) {
          throw Exception(
              'Please wait before requesting another password reset');
        }
      }

      await _supabase.auth.resetPasswordForEmail(email);
      _lastPasswordResetRequest = DateTime.now();
      return true;
    } catch (e) {
      debugPrint('Error requesting password reset: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  // Adicionar novo método para reenviar email de confirmação
  Future<bool> resendConfirmationEmail(String email) async {
    try {
      debugPrint(
          'UserProvider: Tentando reenviar email de confirmação para: $email');
      await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
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

  Future<void> updateUserProfile({
    required String name,
    File? imageFile,
    String? currentAvatarUrl,
    bool avatarCleared = false,
  }) async {
    // Aqui você pode implementar a lógica de upload de imagem, remoção de avatar, etc.
    // Por enquanto, só atualiza o nome e o avatarPath (se fornecido)
    await updateProfile(name, currentAvatarUrl);
  }

  /// Restaura a sessão do usuário ao iniciar o app
  Future<void> restoreSession() async {
    try {
      _isLoading = true;
      notifyListeners();
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;
      if (session != null && user != null) {
        debugPrint(
            'UserProvider: Sessão encontrada ao iniciar o app: \\${user.id}');
        // Buscar usuário no repositório pelo e-mail
        final repoUser = user.email != null
            ? await _userRepository.getUserByEmail(user.email!)
            : null;
        if (repoUser != null) {
          _currentUser = repoUser;
          debugPrint(
              'UserProvider: Usuário restaurado do repositório: \\${repoUser.email}');
        } else {
          // Se não existir no repositório, cria um novo
          _currentUser = await _userRepository.createUser(
            AppUser(
              id: user.id,
              name:
                  user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? '',
              email: user.email ?? '',
              passwordHash: '',
              passwordSalt: '',
              createdAt: DateTime.now(),
            ),
          );
          debugPrint(
              'UserProvider: Usuário criado no repositório a partir da sessão.');
        }
      } else {
        debugPrint(
            'UserProvider: Nenhuma sessão ativa encontrada ao iniciar o app.');
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('UserProvider: Erro ao restaurar sessão: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
