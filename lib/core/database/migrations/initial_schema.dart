import 'package:sqflite/sqflite.dart';

class InitialSchema {
  static Future<void> createTables(Database db) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        avatar_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMP,
        is_active BOOLEAN DEFAULT 1
      )
    ''');

    // UserSettings Table
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        language_code TEXT DEFAULT 'en',
        theme_mode TEXT DEFAULT 'system',
        font_size REAL DEFAULT 1.0,
        notifications_enabled BOOLEAN DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // GameProgress Table
    await db.execute('''
      CREATE TABLE game_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        level INTEGER DEFAULT 1,
        experience INTEGER DEFAULT 0,
        max_score INTEGER DEFAULT 0,
        missions_completed INTEGER DEFAULT 0,
        last_played TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Missions Table
    await db.execute('''
      CREATE TABLE missions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        difficulty_level INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // UserMissions Table
    await db.execute('''
      CREATE TABLE user_missions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mission_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        started_at TIMESTAMP,
        completed_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE
      )
    ''');

    // OnboardingProgress Table
    await db.execute('''
      CREATE TABLE onboarding_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        is_completed BOOLEAN DEFAULT 0,
        last_page INTEGER DEFAULT 0,
        completed_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // PasswordResetTokens Table
    await db.execute('''
      CREATE TABLE password_reset_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        token TEXT NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_used BOOLEAN DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // GameSessions Table
    await db.execute('''
      CREATE TABLE game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        score INTEGER DEFAULT 0,
        duration INTEGER DEFAULT 0,
        started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ended_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute(
        'CREATE INDEX idx_user_settings_user_id ON user_settings(user_id)');
    await db.execute(
        'CREATE INDEX idx_game_progress_user_id ON game_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_user_missions_user_id ON user_missions(user_id)');
    await db.execute(
        'CREATE INDEX idx_user_missions_mission_id ON user_missions(mission_id)');
    await db.execute(
        'CREATE INDEX idx_onboarding_progress_user_id ON onboarding_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id)');
    await db.execute(
        'CREATE INDEX idx_game_sessions_user_id ON game_sessions(user_id)');
  }
}
