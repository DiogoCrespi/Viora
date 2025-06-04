import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/initial_schema.dart';

class DatabaseConfig {
  static const String databaseName = 'viora.db';
  static const int databaseVersion = 1;

  static Future<Database> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (Database db, int version) async {
        await InitialSchema.createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Handle future database upgrades here
      },
    );
  }
}
