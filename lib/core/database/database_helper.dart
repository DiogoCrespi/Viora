import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:viora/core/database/migrations/initial_schema.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'viora.db';
  static const int _dbVersion = 1;

  /// Obtém a instância do banco de dados
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  static Future<Database> _initDatabase() async {
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
      },
    );
  }

  /// Fecha a conexão com o banco de dados
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('Database connection closed');
    }
  }

  /// Limpa todas as tabelas (apenas para desenvolvimento)
  static Future<void> clearDatabase() async {
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
  static Future<void> deleteDatabase() async {
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
  static Future<void> recreateDatabase() async {
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
  static Future<bool> databaseExists() async {
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
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
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
