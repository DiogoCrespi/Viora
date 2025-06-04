import 'package:sqflite/sqflite.dart';
import '../database/database_config.dart';
import '../models/user.dart';
import '../utils/password_utils.dart';

class UserRepository {
  final Database _database;

  UserRepository(this._database);

  static Future<UserRepository> create() async {
    final database = await DatabaseConfig.getDatabase();
    return UserRepository(database);
  }

  Future<User?> getUserByEmail(String email) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User> createUser(String name, String email, String password) async {
    final salt = PasswordUtils.generateSalt();
    final passwordHash = PasswordUtils.hashPassword(password, salt);

    final user = User(
      name: name,
      email: email,
      passwordHash: passwordHash,
      passwordSalt: salt,
      createdAt: DateTime.now(),
    );

    final id = await _database.insert('users', user.toMap());
    return User.fromMap({...user.toMap(), 'id': id});
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

  Future<void> updateLastLogin(int userId) async {
    await _database.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserProfile(
    int userId, {
    String? name,
    String? email,
    String? avatarPath,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (avatarPath != null) updates['avatar_path'] = avatarPath;

    if (updates.isNotEmpty) {
      await _database.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> createPasswordResetToken(
      int userId, String token, DateTime expiresAt) async {
    await _database.insert('password_reset_tokens', {
      'user_id': userId,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'is_used': 0,
    });
  }

  Future<bool> validatePasswordResetToken(String token) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await _database.query(
      'password_reset_tokens',
      where: 'token = ? AND expires_at > ? AND is_used = 0',
      whereArgs: [token, now.toIso8601String()],
    );

    return maps.isNotEmpty;
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    final salt = PasswordUtils.generateSalt();
    final passwordHash = PasswordUtils.hashPassword(newPassword, salt);

    await _database.update(
      'users',
      {
        'password_hash': passwordHash,
        'password_salt': salt,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Mark all reset tokens as used
    await _database.update(
      'password_reset_tokens',
      {'is_used': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
