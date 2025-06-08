import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../config/supabase_config.dart';
import 'package:flutter/foundation.dart';
import '../database/migrations/initial_schema.dart';

class UserRepository {
  static Database? _dbInstance;
  static const String _dbName = 'viora.db';
  static const int _dbVersion = 1;

  Future<Database> get _database async {
    if (_dbInstance != null) return _dbInstance!;
    _dbInstance = await _initDatabase();
    return _dbInstance!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Primeiro, tenta deletar o banco de dados existente para recriar com a estrutura correta
    try {
      await deleteDatabase(path);
      debugPrint('Database deleted successfully');
    } catch (e) {
      debugPrint('Error deleting database: $e');
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        debugPrint('Creating database tables...');
        await InitialSchema.createTables(db);
        debugPrint('Database tables created successfully');
      },
      onOpen: (db) async {
        debugPrint('Database opened successfully');
        // Verifica a estrutura da tabela
        final tableInfo = await db.rawQuery('PRAGMA table_info(users)');
        debugPrint('Table structure: $tableInfo');
      },
    );
  }

  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes).substring(0, 16);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isEmpty) {
        return null;
      }

      final map = maps.first;
      return User(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
        passwordSalt: map['password_salt'] as String,
        avatarPath: map['avatar_path'] as String?,
        createdAt: map['created_at'] as String,
        lastLogin: map['last_login'] as String?,
        isActive: map['is_active'] as int,
      );
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  Future<User?> createUser(String name, String email, String password, String supabaseId) async {
    try {
      debugPrint('Attempting to create user with email: $email');

      // Primeiro, verifica se o usuário já existe
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        debugPrint('User already exists in SQLite');
        return existingUser;
      }

      // Gera salt e hash da senha
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);

      // Cria o usuário no Supabase users table
      final now = DateTime.now().toUtc();
      final createdAt = now.toIso8601String();
      final userData = {
        'id': supabaseId,
        'name': name,
        'email': email,
        'password_hash': hashedPassword,
        'password_salt': salt,
        'created_at': createdAt,
        'is_active': 1,
      };

      debugPrint('Creating user in Supabase users table: $userData');

      try {
        final response = await SupabaseConfig.client
            .from('users')
            .upsert(userData)
            .select()
            .single();

        debugPrint('User created in Supabase users table: $response');

        // Cria o usuário no SQLite
        final db = await _database;
        
        // Verifica a estrutura da tabela antes da inserção
        final tableInfo = await db!.rawQuery('PRAGMA table_info(users)');
        debugPrint('Table structure before insert: $tableInfo');

        // Prepara os dados para inserção no SQLite
        final sqliteData = {
          'id': supabaseId,
          'name': name,
          'email': email,
          'password_hash': hashedPassword,
          'password_salt': salt,
          'created_at': createdAt,
          'last_login': null,
          'is_active': 1,
        };

        debugPrint('Inserting into SQLite with data: $sqliteData');

        final id = await db.insert(
          'users',
          sqliteData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (id == 0) {
          debugPrint('Failed to create user in SQLite');
          return null;
        }

        // Verifica se o usuário foi inserido corretamente
        final insertedUser = await getUserByEmail(email);
        debugPrint('Inserted user from SQLite: $insertedUser');

        return User(
          id: supabaseId,
          name: name,
          email: email,
          passwordHash: hashedPassword,
          passwordSalt: salt,
          avatarPath: null,
          createdAt: createdAt,
          lastLogin: null,
          isActive: 1,
        );
      } catch (e) {
        debugPrint('Supabase error: $e');
        // Se o erro for de chave duplicada, tenta recuperar o usuário existente
        if (e.toString().contains('duplicate key value')) {
          final existingUser = await getUserByEmail(email);
          if (existingUser != null) {
            return existingUser;
          }
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      final db = await _database;
      final now = DateTime.now().toUtc().toIso8601String();
      
      await db!.update(
        'users',
        {'last_login': now},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return false;

      final hashedPassword = _hashPassword(password, user.passwordSalt);
      return hashedPassword == user.passwordHash;
    } catch (e) {
      debugPrint('Error verifying password: $e');
      return false;
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
      await SupabaseConfig.client.from('users').update(updates).eq('id', userId);

      if (_dbInstance != null) {
        await _dbInstance!.update(
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
    if (_dbInstance != null) {
      await _dbInstance!.insert('password_reset_tokens', {
        'user_id': userId,
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'is_used': 0,
      });
    }
  }

  Future<bool> validatePasswordResetToken(String token) async {
    if (_dbInstance != null) {
      final now = DateTime.now();
      final List<Map<String, dynamic>> maps = await _dbInstance!.query(
        'password_reset_tokens',
        where: 'token = ? AND expires_at > ? AND is_used = 0',
        whereArgs: [token, now.toIso8601String()],
      );

      return maps.isNotEmpty;
    }
    return false;
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    final salt = _generateSalt();
    final passwordHash = _hashPassword(newPassword, salt);

    final updates = {
      'password_hash': passwordHash,
      'password_salt': salt,
    };

    await SupabaseConfig.client.from('users').update(updates).eq('id', userId);

    if (_dbInstance != null) {
      await _dbInstance!.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );

      await _markResetTokensAsUsed(userId);
    }
  }

  Future<void> _markResetTokensAsUsed(String userId) async {
    if (_dbInstance != null) {
      await _dbInstance!.update(
        'password_reset_tokens',
        {'is_used': 1},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> _cacheUser(User user) async {
    if (_dbInstance != null) {
      final userData = user.toJson();
      // Converte valores booleanos para inteiros
      if (userData['is_active'] is bool) {
        userData['is_active'] = (userData['is_active'] as bool) ? 1 : 0;
      }
      
      await _dbInstance!.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
