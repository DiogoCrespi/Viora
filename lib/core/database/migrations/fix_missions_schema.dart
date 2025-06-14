import 'package:sqflite/sqflite.dart';

class FixMissionsSchema {
  static const int version = 5;

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

    // Adiciona as colunas created_at e updated_at à tabela missions
    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN created_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna created_at à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna created_at: $e');
    }

    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN updated_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna updated_at à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna updated_at: $e');
    }

    // Adiciona as colunas created_at e updated_at à tabela user_missions
    try {
      await db.execute(
          'ALTER TABLE user_missions ADD COLUMN created_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna created_at à tabela user_missions');
    } catch (e) {
      print('Erro ao adicionar coluna created_at: $e');
    }

    try {
      await db.execute(
          'ALTER TABLE user_missions ADD COLUMN updated_at TEXT DEFAULT (datetime("now", "utc"))');
      print('Adicionada coluna updated_at à tabela user_missions');
    } catch (e) {
      print('Erro ao adicionar coluna updated_at: $e');
    }

    // Adiciona as colunas type e required_score à tabela missions
    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN type TEXT DEFAULT "score" CHECK (type IN ("score", "level"))');
      print('Adicionada coluna type à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna type: $e');
    }

    try {
      await db.execute(
          'ALTER TABLE missions ADD COLUMN required_score INTEGER DEFAULT 0');
      print('Adicionada coluna required_score à tabela missions');
    } catch (e) {
      print('Erro ao adicionar coluna required_score: $e');
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
