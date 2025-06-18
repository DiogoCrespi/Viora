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
    if (kDebugMode) {
      debugPrint('DatabaseHelper: _initDatabase: Database path: $path');
    }

    Future<Database> openDbLocal(String dbPath) async {
      return openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: (db, version) async {
          if (kDebugMode) {
            debugPrint(
                'DatabaseHelper: _initDatabase (onCreate): Creating tables for version $version');
          }
          await InitialSchema.createTables(db);
          // Potentially call specific version migrations if needed from a fresh install
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (kDebugMode) {
            debugPrint(
                'DatabaseHelper: _initDatabase (onUpgrade): Upgrading database from $oldVersion to $newVersion');
          }
          // Migration logic seems correct: apply migrations sequentially.
          if (oldVersion < UpdateMissionsSchema.version) {
            await UpdateMissionsSchema.migrate(db);
            if (kDebugMode) {
              debugPrint(
                  'DatabaseHelper: _initDatabase (onUpgrade): Applied UpdateMissionsSchema');
            }
          }
          if (oldVersion < FixUserMissionsSchema.version) {
            await FixUserMissionsSchema.migrate(db);
            if (kDebugMode) {
              debugPrint(
                  'DatabaseHelper: _initDatabase (onUpgrade): Applied FixUserMissionsSchema');
            }
          }
          if (oldVersion < FixMissionsSchema.version) {
            await FixMissionsSchema.migrate(db);
            if (kDebugMode) {
              debugPrint(
                  'DatabaseHelper: _initDatabase (onUpgrade): Applied FixMissionsSchema');
            }
          }
          if (oldVersion < FixMissionsSchemaV2.version) {
            await FixMissionsSchemaV2.migrate(db);
            if (kDebugMode) {
              debugPrint(
                  'DatabaseHelper: _initDatabase (onUpgrade): Applied FixMissionsSchemaV2');
            }
          }
        },
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: _initDatabase: Attempting to open existing database.');
      }
      return await openDbLocal(path);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: _initDatabase: Error opening database: $e\nStackTrace: $stackTrace');
        debugPrint(
            'DatabaseHelper: _initDatabase: Attempting to delete and recreate the database.');
      }

      try {
        await databaseFactory.deleteDatabase(path);
        if (kDebugMode) {
          debugPrint(
              'DatabaseHelper: _initDatabase: Successfully deleted old database.');
        }
        return await openDbLocal(path); // Try opening (and creating) again
      } catch (deleteError, deleteStackTrace) {
        if (kDebugMode) {
          debugPrint(
              'DatabaseHelper: _initDatabase: CRITICAL ERROR: Failed to delete and recreate database: $deleteError\nStackTrace: $deleteStackTrace');
        }
        // If deletion and recreation also fail, rethrow the original error or a new one.
        throw Exception(
            'Failed to initialize database after multiple attempts: $deleteError');
      }
    }
  }

  /// Fecha a conexão com o banco de dados
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      if (kDebugMode) {
        debugPrint('DatabaseHelper: closeDatabase: Database connection closed.');
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: closeDatabase: Database was not open, no action taken.');
      }
    }
  }

  /// Limpa todas as tabelas (apenas para desenvolvimento)
  Future<void> clearDatabase() async {
    if (kReleaseMode) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: clearDatabase: Cannot clear database in release mode.');
      }
      return;
    }

    try {
      final db = await database;
      await InitialSchema.clearAllTables(db);
      if (kDebugMode) {
        debugPrint('DatabaseHelper: clearDatabase: Database cleared successfully.');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: clearDatabase: Error clearing database: $e\nStackTrace: $stackTrace');
      }
    }
  }

  /// Deleta o banco de dados completamente (apenas para desenvolvimento)
  Future<void> deleteDatabase() async {
    if (kReleaseMode) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: deleteDatabase: Cannot delete database in release mode.');
      }
      return;
    }

    try {
      await closeDatabase(); // Ensure DB is closed before deleting
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      await databaseFactory.deleteDatabase(path);
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: deleteDatabase: Database deleted successfully from path: $path');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: deleteDatabase: Error deleting database: $e\nStackTrace: $stackTrace');
      }
    }
  }

  /// Recria o banco de dados (apenas para desenvolvimento)
  Future<void> recreateDatabase() async {
    if (kReleaseMode) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: recreateDatabase: Cannot recreate database in release mode.');
      }
      return;
    }

    try {
      await deleteDatabase();
      _database = await _initDatabase(); // Explicitly re-initialize and assign
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: recreateDatabase: Database recreated successfully.');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: recreateDatabase: Error recreating database: $e\nStackTrace: $stackTrace');
      }
    }
  }

  /// Verifica se o banco de dados existe
  Future<bool> databaseExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    try {
      final exists = await databaseFactory.databaseExists(path);
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: databaseExists: Database at $path ${exists ? "exists" : "does not exist"}.');
      }
      return exists;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: databaseExists: Error checking if database exists at $path: $e\nStackTrace: $stackTrace');
      }
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
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: getDatabaseInfo: Fetched table names: $tableNames');
      }
      return {
        'version': await db.getVersion(), // Get actual DB version
        'path': db.path,
        'tables': tableNames,
        'tableCount': tableNames.length,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: getDatabaseInfo: Error fetching database info: $e\nStackTrace: $stackTrace');
      }
      return {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
    }
  }

  /// Força a migração do banco de dados (apenas para desenvolvimento)
  Future<void> forceMigration() async {
    // This method is inherently for development/testing.
    // A kReleaseMode check might be redundant if it's not exposed to UI in prod.
    if (kReleaseMode) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: forceMigration: Cannot force migration in release mode.');
      }
      return;
    }
    try {
      if (kDebugMode) {
        debugPrint('DatabaseHelper: forceMigration: Starting forced migration...');
      }
      await closeDatabase();
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: forceMigration: Deleting existing database at $path for migration.');
      }
      await databaseFactory.deleteDatabase(path);

      // Re-initialize the database, which will trigger onCreate and onUpgrade as needed.
      _database = await _initDatabase();

      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: forceMigration: Database migration forced successfully.');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'DatabaseHelper: forceMigration: Error forcing database migration: $e\nStackTrace: $stackTrace');
      }
      rethrow; // Rethrow as this is a significant operation, caller should know.
    }
  }
}
