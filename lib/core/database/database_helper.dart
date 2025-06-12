import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:viora/core/database/migrations/initial_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String _dbName = 'viora.db';
  static const int _dbVersion = 1;

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
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
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
        last_played TEXT NOT NULL
      )
    ''');

    // Tabela de missões
    await db.execute('''
      CREATE TABLE missions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        required_score INTEGER NOT NULL,
        reward_experience INTEGER NOT NULL,
        difficulty TEXT NOT NULL
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
        'title': 'Iniciante',
        'description': 'Alcance 1000 pontos em uma partida',
        'required_score': 1000,
        'reward_experience': 500,
        'difficulty': 'easy',
      },
      {
        'id': 'mission_2',
        'title': 'Intermediário',
        'description': 'Alcance 5000 pontos em uma partida',
        'required_score': 5000,
        'reward_experience': 2000,
        'difficulty': 'medium',
      },
      {
        'id': 'mission_3',
        'title': 'Avançado',
        'description': 'Alcance 10000 pontos em uma partida',
        'required_score': 10000,
        'reward_experience': 5000,
        'difficulty': 'hard',
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
}
