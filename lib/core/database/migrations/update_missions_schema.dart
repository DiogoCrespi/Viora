import 'package:sqflite/sqflite.dart';

class UpdateMissionsSchema {
  static const int version = 2;

  /// Atualiza o schema para incluir as novas colunas
  static Future<void> migrate(Database db) async {
    // Adiciona a coluna required_level à tabela missions
    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN required_level INTEGER DEFAULT 1');
      print('Adicionada coluna required_level à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna required_level: $e');
    }

    // Adiciona a coluna updated_at à tabela user_missions
    try {
      await db.execute(
          'ALTER TABLE user_missions ADD COLUMN updated_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna updated_at à tabela user_missions');
    } catch (e) {
      print('Erro ao adicionar coluna updated_at: $e');
    }

    // Remove a coluna status da tabela missions (se existir)
    try {
      await db.execute('ALTER TABLE missions DROP COLUMN status');
      print('Removida coluna status da tabela missions');
    } catch (e) {
      print('Erro ao remover coluna status: $e');
    }

    // Atualiza as missões existentes com os níveis necessários
    try {
      final missions = [
        {
          'id': '00000000-0000-0000-0000-000000000001',
          'title': 'Início da Jornada',
          'description': 'Alcance o nível 1 para começar sua aventura espacial',
          'xp_reward': 100,
          'difficulty_level': 1,
          'required_level': 1,
        },
        {
          'id': '00000000-0000-0000-0000-000000000002',
          'title': 'Nebulosa',
          'description': 'Alcance o nível 2 para explorar a Nebulosa',
          'xp_reward': 200,
          'difficulty_level': 2,
          'required_level': 2,
        },
        {
          'id': '00000000-0000-0000-0000-000000000003',
          'title': 'Galáxia',
          'description': 'Alcance o nível 3 para viajar pela Galáxia',
          'xp_reward': 300,
          'difficulty_level': 3,
          'required_level': 3,
        },
        {
          'id': '00000000-0000-0000-0000-000000000004',
          'title': 'Super Nova',
          'description': 'Alcance o nível 4 para testemunhar uma Super Nova',
          'xp_reward': 400,
          'difficulty_level': 4,
          'required_level': 4,
        },
        {
          'id': '00000000-0000-0000-0000-000000000005',
          'title': 'Buraco Negro',
          'description': 'Alcance o nível 5 para enfrentar o Buraco Negro',
          'xp_reward': 500,
          'difficulty_level': 5,
          'required_level': 5,
        },
      ];

      for (var mission in missions) {
        await db.insert(
          'missions',
          mission,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Atualizadas missões com níveis necessários');
    } catch (e) {
      print('Erro ao atualizar missões: $e');
    }
  }
}
