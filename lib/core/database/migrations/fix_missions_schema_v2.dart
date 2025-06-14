import 'package:sqflite/sqflite.dart';

class FixMissionsSchemaV2 {
  static const int version = 6;

  /// Corrige o schema das tabelas missions e user_missions
  static Future<void> migrate(Database db) async {
    // Verifica se a coluna difficulty_level existe na tabela missions
    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN difficulty_level INTEGER DEFAULT 1');
      print('Adicionada coluna difficulty_level à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna difficulty_level: $e');
    }

    // Atualiza as missões existentes com os valores corretos
    try {
      final missions = [
        {
          'id': 'mission_1',
          'title': 'Primeiros Passos',
          'description': 'Alcance 100 pontos em uma partida',
          'type': 'score',
          'required_score': 100,
          'required_level': 1,
          'xp_reward': 50,
          'difficulty_level': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'mission_2',
          'title': 'Iniciante',
          'description': 'Alcance 500 pontos em uma partida',
          'type': 'score',
          'required_score': 500,
          'required_level': 1,
          'xp_reward': 100,
          'difficulty_level': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'mission_3',
          'title': 'Intermediário',
          'description': 'Alcance o nível 2',
          'type': 'level',
          'required_score': 0,
          'required_level': 2,
          'xp_reward': 150,
          'difficulty_level': 2,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'mission_4',
          'title': 'Avançado',
          'description': 'Alcance 1000 pontos em uma partida',
          'type': 'score',
          'required_score': 1000,
          'required_level': 2,
          'xp_reward': 200,
          'difficulty_level': 2,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'mission_5',
          'title': 'Mestre',
          'description': 'Alcance o nível 3',
          'type': 'level',
          'required_score': 0,
          'required_level': 3,
          'xp_reward': 300,
          'difficulty_level': 3,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      for (var mission in missions) {
        await db.insert(
          'missions',
          mission,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Atualizadas missões com valores corretos');
    } catch (e) {
      print('Erro ao atualizar missões: $e');
    }
  }
}
