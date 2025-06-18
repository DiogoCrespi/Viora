import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:viora/features/user/domain/entities/app_user_entity.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:viora/core/database/migrations/initial_schema.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

abstract class IUserRepository {
  Future<AppUser?> getUserByEmail(String email);
  Future<AppUser> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<void> deleteUser(String id);
}

class SupabaseUserRepository implements IUserRepository {
  final SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      final response =
          await _client.from('users').select().eq('email', email).single();

      if (response == null) return null;

      return AppUser.fromJson(response);
    } catch (e) {
      debugPrint('Supabase error: $e');
      return null;
    }
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    try {
      final response =
          await _client.from('users').insert(user.toJson()).select().single();
      return AppUser.fromJson(response);
    } catch (e) {
      debugPrint('Supabase error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(AppUser user) async {
    try {
      await _client.from('users').update(user.toJson()).eq('id', user.id);
    } catch (e) {
      debugPrint('Supabase error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
    } catch (e) {
      debugPrint('Supabase error: $e');
      rethrow;
    }
  }
}

class SQLiteUserRepository implements IUserRepository {
  final Database _db;

  SQLiteUserRepository(this._db) {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await InitialSchema.createTables(_db);
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isEmpty) return null;
      return AppUser(
        id: maps.first['id'] as String,
        name: maps.first['name'] as String,
        email: maps.first['email'] as String,
        passwordHash: maps.first['password_hash'] as String? ?? '',
        passwordSalt: maps.first['password_salt'] as String? ?? '',
        avatarPath: maps.first['avatar_path'] as String?,
        createdAt: DateTime.parse(maps.first['created_at'] as String),
        lastLogin: maps.first['last_login'] != null
            ? DateTime.parse(maps.first['last_login'] as String)
            : null,
        isActive: (maps.first['is_active'] as int) == 1,
      );
    } catch (e) {
      debugPrint('SQLite error: $e');
      return null;
    }
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    try {
      final userData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'password_hash': user.passwordHash,
        'password_salt': user.passwordSalt,
        'avatar_path': user.avatarPath,
        'created_at': user.createdAt.toIso8601String(),
        'last_login': user.lastLogin?.toIso8601String(),
        'is_active': user.isActive ? 1 : 0,
      };

      await _db.insert('users', userData);
      return user;
    } catch (e) {
      debugPrint('SQLite error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(AppUser user) async {
    try {
      final userData = {
        'name': user.name,
        'email': user.email,
        'password_hash': user.passwordHash,
        'password_salt': user.passwordSalt,
        'avatar_path': user.avatarPath,
        'created_at': user.createdAt.toIso8601String(),
        'last_login': user.lastLogin?.toIso8601String(),
        'is_active': user.isActive ? 1 : 0,
      };

      await _db.update(
        'users',
        userData,
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      debugPrint('SQLite error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('SQLite error: $e');
      rethrow;
    }
  }
}

// Factory para criar o repositório apropriado
class UserRepositoryFactory {
  static IUserRepository create(SupabaseClient supabaseClient, [Database? db]) {
    if (!kIsWeb && db != null) {
      return SQLiteUserRepository(db);
    }
    return SupabaseUserRepository(supabaseClient);
  }
}

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

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        debugPrint('Creating database tables...');
        await InitialSchema.createTables(db);
        debugPrint('Database tables created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint('Upgrading database from version $oldVersion to $newVersion');
        await InitialSchema.createTables(db);
        debugPrint('Database upgrade completed');
      },
      onOpen: (db) async {
        debugPrint('Database opened successfully');
        // Verifica a estrutura da tabela
        try {
          final tableInfo = await db.rawQuery('PRAGMA table_info(users)');
          debugPrint('Table structure: $tableInfo');
        } catch (e) {
          debugPrint('Error checking table structure: $e');
        }
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

  Future<AppUser?> getUserByEmail(String email) async {
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
      return AppUser(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String? ?? '',
        passwordSalt: map['password_salt'] as String? ?? '',
        avatarPath: map['avatar_path'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        lastLogin: map['last_login'] != null
            ? DateTime.parse(map['last_login'] as String)
            : null,
        isActive: (map['is_active'] as int) == 1,
      );
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  Future<AppUser?> createUser(
      String name, String email, String password, String supabaseId) async {
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

        return AppUser(
          id: supabaseId,
          name: name,
          email: email,
          passwordHash: hashedPassword,
          passwordSalt: salt,
          avatarPath: null,
          createdAt: DateTime.now(),
          lastLogin: null,
          isActive: true,
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
      await SupabaseConfig.client
          .from('users')
          .update(updates)
          .eq('id', userId);

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

  Future<void> _cacheUser(AppUser user) async {
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
