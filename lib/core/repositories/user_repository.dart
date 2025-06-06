import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/database_config.dart';
import '../models/user.dart';
import '../utils/password_utils.dart';
import '../config/supabase_config.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class UserRepository {
  final Database? _database;
  final _supabase = SupabaseConfig.client;

  UserRepository(this._database);

  static Future<UserRepository> create() async {
    if (kIsWeb) {
      return UserRepository(null);
    }
    final database = await DatabaseConfig.getDatabase();
    return UserRepository(database);
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final response =
          await _supabase.from('users').select().eq('email', email).single();
      final user = User.fromJson(response);

      if (!kIsWeb && _database != null) {
        await _cacheUser(user);
      }
      return user;
    } on supabase.PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      rethrow;
    } catch (e) {
      if (!kIsWeb && _database != null) {
        final List<Map<String, dynamic>> maps = await _database!.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );

        if (maps.isNotEmpty) {
          return User.fromJson(maps.first);
        }
      }
      return null;
    }
  }

  Future<User> createUser(String name, String email, String password) async {
    try {
      // Validação de email mais simples
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
        debugPrint('Email validation failed for: $email');
        throw Exception('registerErrorInvalidEmail');
      }

      debugPrint('Attempting to create user with email: $email'); // Debug log

      final salt = PasswordUtils.generateSalt();
      final passwordHash = PasswordUtils.hashPassword(password, salt);

      // Criar dados do usuário
      final userData = {
        'name': name,
        'email': email.trim().toLowerCase(),
        'password_hash': passwordHash,
        'password_salt': salt,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      };

      debugPrint('Creating user in Supabase: $userData'); // Debug log

      // Inserir diretamente na tabela users
      final response = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('registerErrorServerUnavailable');
        },
      );

      debugPrint('Supabase response: $response'); // Debug log

      final createdUser = User.fromJson(response);

      if (!kIsWeb && _database != null) {
        await _cacheUser(createdUser);
      }

      return createdUser;
    } on supabase.PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message} (code: ${e.code})'); // Debug log
      switch (e.code) {
        case '23505': // Unique violation
          throw Exception('registerErrorEmailInUse');
        case '23514': // Check violation
          throw Exception('registerErrorInvalidData');
        case '42501': // Permission denied
          throw Exception('registerErrorPermissionDenied');
        default:
          throw Exception('registerError');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e'); // Debug log
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        throw Exception('registerErrorNoConnection');
      }
      if (e.toString().contains('timeout')) {
        throw Exception('registerErrorServerUnavailable');
      }
      if (e.toString().contains('registerErrorInvalidEmail')) {
        throw Exception('registerErrorInvalidEmail');
      }
      throw Exception('registerError');
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;

    return PasswordUtils.verifyPassword(
      password,
      user.passwordHash,
      user.passwordSalt,
    );
  }

  Future<void> updateLastLogin(String userId) async {
    final now = DateTime.now().toIso8601String();

    await _supabase.from('users').update({'last_login': now}).eq('id', userId);

    if (!kIsWeb && _database != null) {
      await _database!.update(
        'users',
        {'last_login': now},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> updateUserProfile(
    String userId, {
    String? name,
    String? email,
    String? avatarPath,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (avatarPath != null) updates['avatar_path'] = avatarPath;

    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', userId);

      if (!kIsWeb && _database != null) {
        await _database!.update(
          'users',
          updates,
          where: 'id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  Future<void> createPasswordResetToken(
      String userId, String token, DateTime expiresAt) async {
    if (!kIsWeb && _database != null) {
      await _database!.insert('password_reset_tokens', {
        'user_id': userId,
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'is_used': 0,
      });
    }
  }

  Future<bool> validatePasswordResetToken(String token) async {
    if (!kIsWeb && _database != null) {
      final now = DateTime.now();
      final List<Map<String, dynamic>> maps = await _database!.query(
        'password_reset_tokens',
        where: 'token = ? AND expires_at > ? AND is_used = 0',
        whereArgs: [token, now.toIso8601String()],
      );

      return maps.isNotEmpty;
    }
    return false;
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    final salt = PasswordUtils.generateSalt();
    final passwordHash = PasswordUtils.hashPassword(newPassword, salt);

    final updates = {
      'password_hash': passwordHash,
      'password_salt': salt,
    };

    await _supabase.from('users').update(updates).eq('id', userId);

    if (!kIsWeb && _database != null) {
      await _database!.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      await _markResetTokensAsUsed(userId);
    }
  }

  Future<void> _markResetTokensAsUsed(String userId) async {
    if (!kIsWeb && _database != null) {
      await _database!.update(
        'password_reset_tokens',
        {'is_used': 1},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> _cacheUser(User user) async {
    if (!kIsWeb && _database != null) {
      await _database!.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
