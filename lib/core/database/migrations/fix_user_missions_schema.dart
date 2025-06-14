import 'package:sqflite/sqflite.dart';

class FixUserMissionsSchema {
  static const int version = 3;

  /// Corrige o schema da tabela user_missions
  static Future<void> migrate(Database db) async {
    // Adiciona a coluna updated_at à tabela user_missions
    try {
      await db.execute(
          'ALTER TABLE user_missions ADD COLUMN updated_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna updated_at à tabela user_missions');
    } catch (e) {
      print('Erro ao adicionar coluna updated_at: $e');
    }
  }
}
