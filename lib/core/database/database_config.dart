import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:viora/core/platform/platform_stub.dart' if (dart.library.io) 'package:viora/core/platform/platform_io.dart';

class DatabaseConfig {
  static Future<Database> getDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }

    // Initialize FFI for desktop platforms
    if (!kIsWeb && Platform.isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'viora.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            avatar_path TEXT,
            created_at TEXT NOT NULL,
            last_login TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE password_reset_tokens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            token TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_used INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }
}
