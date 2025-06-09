import 'package:sqflite/sqflite.dart';

class InitialSchema {
  static Future<void> createTables(Database db) async {
    // Users Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT,
        password_salt TEXT,
        avatar_path TEXT,
        created_at TEXT NOT NULL,
        last_login TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // UserSettings Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE user_settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT DEFAULT 'en',
        theme_mode TEXT DEFAULT 'system',
        font_size REAL DEFAULT 1.0,
        notifications_enabled INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // GameProgress Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE game_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        experience INTEGER DEFAULT 0,
        max_score INTEGER DEFAULT 0,
        missions_completed INTEGER DEFAULT 0,
        last_played TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Missions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE missions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        difficulty_level INTEGER DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now', 'utc'))
      )
    ''');

    // UserMissions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE user_missions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mission_id TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        started_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE
      )
    ''');

    // OnboardingProgress Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE onboarding_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        last_page INTEGER DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // PasswordResetTokens Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS password_reset_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_used INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // GameSessions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE game_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        duration INTEGER DEFAULT 0,
        started_at TEXT DEFAULT (datetime('now', 'utc')),
        ended_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // UserPreferences Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        user_id TEXT PRIMARY KEY,
        theme_mode TEXT,
        language TEXT,
        font_size REAL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
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
    await db.execute(
        'CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id)');
  }
}
