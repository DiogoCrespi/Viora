import 'package:sqflite/sqflite.dart';

class InitialSchema {
  static const int currentVersion = 1;

  /// Cria todas as tabelas do schema inicial
  static Future<void> createTables(Database db) async {
    // Verifica se já existe uma tabela de controle de versão
    await _createVersionTable(db);

    // Verifica a versão atual do schema
    final currentDbVersion = await _getCurrentVersion(db);

    if (currentDbVersion < currentVersion) {
      // Executa as migrações necessárias
      await _migrateSchema(db, currentDbVersion);
      await _updateVersion(db, currentVersion);
    }
  }

  /// Cria a tabela de controle de versão
  static Future<void> _createVersionTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_version (
        id INTEGER PRIMARY KEY,
        version INTEGER NOT NULL,
        applied_at TEXT DEFAULT (datetime('now', 'utc'))
      )
    ''');
  }

  /// Obtém a versão atual do schema
  static Future<int> _getCurrentVersion(Database db) async {
    try {
      final result = await db.query(
        'schema_version',
        orderBy: 'version DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first['version'] as int;
      }
    } catch (e) {
      // Se a tabela não existe, retorna 0
      print('Schema version table not found, starting from version 0');
    }

    return 0;
  }

  /// Atualiza a versão do schema
  static Future<void> _updateVersion(Database db, int version) async {
    await db.insert('schema_version', {
      'version': version,
      'applied_at': DateTime.now().toIso8601String(),
    });
  }

  /// Executa as migrações baseado na versão atual
  static Future<void> _migrateSchema(Database db, int fromVersion) async {
    if (fromVersion < 1) {
      await _createVersion1Tables(db);
    }
  }

  /// Cria as tabelas da versão 1
  static Future<void> _createVersion1Tables(Database db) async {
    // Users Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        avatar_path TEXT,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        last_login TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // UserSettings Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT DEFAULT 'en',
        theme_mode TEXT DEFAULT 'system',
        font_size REAL DEFAULT 1.0,
        notifications_enabled INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // UserPreferences Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL UNIQUE,
        theme_mode TEXT DEFAULT 'system',
        language TEXT DEFAULT 'pt',
        font_size TEXT DEFAULT 'medium',
        avatar_url TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'utc')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'utc')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // GameProgress Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        experience INTEGER DEFAULT 0,
        max_score INTEGER DEFAULT 0,
        missions_completed INTEGER DEFAULT 0,
        last_played TEXT,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        updated_at TEXT DEFAULT (datetime('now', 'utc')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Missions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS missions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('score', 'level')),
        required_score INTEGER NOT NULL DEFAULT 0,
        required_level INTEGER NOT NULL DEFAULT 1,
        xp_reward INTEGER NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        updated_at TEXT DEFAULT (datetime('now', 'utc'))
      )
    ''');

    // UserMissions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_missions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mission_id TEXT NOT NULL,
        status TEXT DEFAULT 'available' CHECK (status IN ('locked', 'available', 'completed')),
        started_at TEXT,
        completed_at TEXT,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        updated_at TEXT DEFAULT (datetime('now', 'utc')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE,
        UNIQUE(user_id, mission_id)
      )
    ''');

    // GameScores Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_scores (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // GameSessions Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        duration INTEGER DEFAULT 0,
        started_at TEXT DEFAULT (datetime('now', 'utc')),
        ended_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // OnboardingProgress Table - Ajustado para corresponder ao Supabase
    await db.execute('''
      CREATE TABLE IF NOT EXISTS onboarding_progress (
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
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'utc')),
        is_used INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  /// Cria os índices para melhor performance
  static Future<void> _createIndexes(Database db) async {
    // Verifica se os índices já existem antes de criá-los
    final indexes = [
      'idx_users_email',
      'idx_user_settings_user_id',
      'idx_user_preferences_user_id',
      'idx_game_progress_user_id',
      'idx_user_missions_user_id',
      'idx_user_missions_mission_id',
      'idx_onboarding_progress_user_id',
      'idx_password_reset_tokens_user_id',
      'idx_game_sessions_user_id',
      'idx_game_scores_user_id',
    ];

    for (final indexName in indexes) {
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS $indexName ON ${_getTableName(indexName)}(${_getColumnName(indexName)})');
      } catch (e) {
        // Ignora erros de índices já existentes
        print('Index $indexName already exists or error: $e');
      }
    }
  }

  /// Limpa todas as tabelas (útil para desenvolvimento)
  static Future<void> clearAllTables(Database db) async {
    final tables = [
      'game_scores',
      'game_sessions',
      'password_reset_tokens',
      'user_missions',
      'onboarding_progress',
      'game_progress',
      'user_preferences',
      'user_settings',
      'missions',
      'users',
      'schema_version',
    ];

    for (final table in tables) {
      try {
        await db.execute('DROP TABLE IF EXISTS $table');
        print('Dropped table: $table');
      } catch (e) {
        print('Error dropping table $table: $e');
      }
    }
  }

  /// Retorna o nome da tabela baseado no nome do índice
  static String _getTableName(String indexName) {
    switch (indexName) {
      case 'idx_users_email':
        return 'users';
      case 'idx_user_settings_user_id':
        return 'user_settings';
      case 'idx_user_preferences_user_id':
        return 'user_preferences';
      case 'idx_game_progress_user_id':
        return 'game_progress';
      case 'idx_user_missions_user_id':
      case 'idx_user_missions_mission_id':
        return 'user_missions';
      case 'idx_onboarding_progress_user_id':
        return 'onboarding_progress';
      case 'idx_password_reset_tokens_user_id':
        return 'password_reset_tokens';
      case 'idx_game_sessions_user_id':
        return 'game_sessions';
      case 'idx_game_scores_user_id':
        return 'game_scores';
      default:
        return 'users';
    }
  }

  /// Retorna o nome da coluna baseado no nome do índice
  static String _getColumnName(String indexName) {
    switch (indexName) {
      case 'idx_users_email':
        return 'email';
      case 'idx_user_settings_user_id':
      case 'idx_user_preferences_user_id':
      case 'idx_game_progress_user_id':
      case 'idx_user_missions_user_id':
      case 'idx_onboarding_progress_user_id':
      case 'idx_password_reset_tokens_user_id':
      case 'idx_game_sessions_user_id':
      case 'idx_game_scores_user_id':
        return 'user_id';
      case 'idx_user_missions_mission_id':
        return 'mission_id';
      default:
        return 'id';
    }
  }
}
