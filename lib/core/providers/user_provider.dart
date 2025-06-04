import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    final isValid = await _userRepository.verifyPassword(email, password);
    if (isValid) {
      final user = await _userRepository.getUserByEmail(email);
      if (user != null) {
        _currentUser = user;
        await _userRepository.updateLastLogin(user.id!);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final user = await _userRepository.createUser(name, email, password);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatarPath,
  }) async {
    if (_currentUser == null) return false;

    try {
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
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) return false;

      final token = DateTime.now().millisecondsSinceEpoch.toString();
      final expiresAt = DateTime.now().add(const Duration(hours: 24));

      await _userRepository.createPasswordResetToken(
        user.id!,
        token,
        expiresAt,
      );

      // TODO: Send email with reset token
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // Get user from email
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) return false;

      // Check if new password is different from current password
      final isCurrentPassword =
          await _userRepository.verifyPassword(email, newPassword);
      if (isCurrentPassword) return false;

      // Update password
      await _userRepository.updatePassword(user.id!, newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }
}
