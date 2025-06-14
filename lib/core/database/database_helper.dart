import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:viora/core/database/migrations/initial_schema.dart';
import 'package:viora/core/database/migrations/update_missions_schema.dart';
import 'package:viora/core/database/migrations/fix_user_missions_schema.dart';
import 'package:viora/core/database/migrations/fix_missions_schema.dart';
import 'package:viora/core/database/migrations/fix_missions_schema_v2.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String _dbName = 'viora.db';
  static const int _dbVersion = FixMissionsSchemaV2.version;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Obtém a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    try {
      // Tenta abrir o banco existente
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          await InitialSchema.createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < UpdateMissionsSchema.version) {
            await UpdateMissionsSchema.migrate(db);
          }
          if (oldVersion < FixUserMissionsSchema.version) {
            await FixUserMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchema.version) {
            await FixMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchemaV2.version) {
            await FixMissionsSchemaV2.migrate(db);
          }
        },
      );
    } catch (e) {
      debugPrint('Erro ao abrir banco de dados: $e');
      debugPrint('Tentando recriar o banco de dados...');

      // Se houver erro, deleta o banco e recria
      await databaseFactory.deleteDatabase(path);

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          await InitialSchema.createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < UpdateMissionsSchema.version) {
            await UpdateMissionsSchema.migrate(db);
          }
          if (oldVersion < FixUserMissionsSchema.version) {
            await FixUserMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchema.version) {
            await FixMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchemaV2.version) {
            await FixMissionsSchemaV2.migrate(db);
          }
        },
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de sessões do jogo
    await db.execute('''
      CREATE TABLE game_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT NOT NULL
      )
    ''');

    // Tabela de progresso do jogo
    await db.execute('''
      CREATE TABLE game_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        level INTEGER NOT NULL,
        experience INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        missions_completed INTEGER NOT NULL,
        last_played TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'utc')),
        updated_at TEXT DEFAULT (datetime('now', 'utc'))
      )
    ''');

    // Tabela de missões
    await db.execute('''
      CREATE TABLE missions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        difficulty_level INTEGER NOT NULL,
        required_level INTEGER NOT NULL
      )
    ''');

    // Tabela de missões do usuário
    await db.execute('''
      CREATE TABLE user_missions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mission_id TEXT NOT NULL,
        status TEXT NOT NULL,
        started_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (mission_id) REFERENCES missions (id)
      )
    ''');

    // Inserir missões padrão
    await _insertDefaultMissions(db);
  }

  Future<void> _insertDefaultMissions(Database db) async {
    final missions = [
      {
        'id': 'mission_1',
        'title': 'Início da Jornada',
        'description': 'Alcance o nível 1 para começar sua aventura espacial',
        'xp_reward': 100,
        'difficulty_level': 1,
        'required_level': 1,
      },
      {
        'id': 'mission_2',
        'title': 'Nebulosa',
        'description': 'Alcance o nível 2 para explorar a Nebulosa',
        'xp_reward': 200,
        'difficulty_level': 2,
        'required_level': 2,
      },
      {
        'id': 'mission_3',
        'title': 'Galáxia',
        'description': 'Alcance o nível 3 para viajar pela Galáxia',
        'xp_reward': 300,
        'difficulty_level': 3,
        'required_level': 3,
      },
      {
        'id': 'mission_4',
        'title': 'Super Nova',
        'description': 'Alcance o nível 4 para testemunhar uma Super Nova',
        'xp_reward': 400,
        'difficulty_level': 4,
        'required_level': 4,
      },
      {
        'id': 'mission_5',
        'title': 'Buraco Negro',
        'description': 'Alcance o nível 5 para enfrentar o Buraco Negro',
        'xp_reward': 500,
        'difficulty_level': 5,
        'required_level': 5,
      },
    ];

    for (var mission in missions) {
      await db.insert('missions', mission);
    }
  }

  /// Fecha a conexão com o banco de dados
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('Database connection closed');
    }
  }

  /// Limpa todas as tabelas (apenas para desenvolvimento)
  Future<void> clearDatabase() async {
    if (kReleaseMode) {
      debugPrint('Cannot clear database in release mode');
      return;
    }

    try {
      final db = await database;
      await InitialSchema.clearAllTables(db);
      debugPrint('Database cleared successfully');
    } catch (e) {
      debugPrint('Error clearing database: $e');
    }
  }

  /// Deleta o banco de dados completamente (apenas para desenvolvimento)
  Future<void> deleteDatabase() async {
    if (kReleaseMode) {
      debugPrint('Cannot delete database in release mode');
      return;
    }

    try {
      await closeDatabase();
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      await databaseFactory.deleteDatabase(path);
      debugPrint('Database deleted successfully');
    } catch (e) {
      debugPrint('Error deleting database: $e');
    }
  }

  /// Recria o banco de dados (apenas para desenvolvimento)
  Future<void> recreateDatabase() async {
    if (kReleaseMode) {
      debugPrint('Cannot recreate database in release mode');
      return;
    }

    try {
      await deleteDatabase();
      await database; // Recria o banco
      debugPrint('Database recreated successfully');
    } catch (e) {
      debugPrint('Error recreating database: $e');
    }
  }

  /// Verifica se o banco de dados existe
  Future<bool> databaseExists() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      final db = await openDatabase(path);
      await db.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações sobre o banco de dados
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");

      final tableNames =
          tables.map((table) => table['name'] as String).toList();

      return {
        'version': _dbVersion,
        'tables': tableNames,
        'tableCount': tableNames.length,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Força a migração do banco de dados
  Future<void> forceMigration() async {
    try {
      await closeDatabase();
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      // Deleta o banco de dados existente
      await databaseFactory.deleteDatabase(path);
      debugPrint('Database deleted for migration');

      // Abre o banco com a nova versão para forçar a migração
      _database = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: (db, version) async {
          await InitialSchema.createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < UpdateMissionsSchema.version) {
            await UpdateMissionsSchema.migrate(db);
          }
          if (oldVersion < FixUserMissionsSchema.version) {
            await FixUserMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchema.version) {
            await FixMissionsSchema.migrate(db);
          }
          if (oldVersion < FixMissionsSchemaV2.version) {
            await FixMissionsSchemaV2.migrate(db);
          }
        },
      );

      debugPrint('Database migration forced successfully');
    } catch (e) {
      debugPrint('Error forcing database migration: $e');
      rethrow;
    }
  }
}
