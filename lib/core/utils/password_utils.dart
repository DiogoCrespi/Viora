import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class PasswordUtils {
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static bool verifyPassword(
      String password, String storedHash, String storedSalt) {
    final hash = hashPassword(password, storedSalt);
    return hash == storedHash;
  }
}
