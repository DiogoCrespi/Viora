import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/initial_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'viora.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await InitialSchema.createTables(db);
      },
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
