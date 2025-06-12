import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/core/database/database_helper.dart';

class GameRepository {
  final DatabaseHelper _dbHelper;
  final SupabaseClient _supabase;

  GameRepository()
      : _dbHelper = DatabaseHelper(),
        _supabase = SupabaseConfig.client;

  // Salvar pontuação do jogo
  Future<void> saveGameScore({
    required String userId,
    required int score,
    required int duration,
  }) async {
    try {
      // Salvar localmente
      final db = await _dbHelper.database;
      await db.insert('game_sessions', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'score': score,
        'duration': duration,
        'started_at': DateTime.now().toIso8601String(),
        'ended_at': DateTime.now().toIso8601String(),
      });

      // Atualizar progresso do jogo
      await _updateGameProgress(userId, score);

      // Salvar no Supabase
      await _supabase.from('game_sessions').insert({
        'user_id': userId,
        'score': score,
        'duration': duration,
        'started_at': DateTime.now().toIso8601String(),
        'ended_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erro ao salvar pontuação: $e');
      rethrow;
    }
  }

  // Atualizar progresso do jogo
  Future<void> _updateGameProgress(String userId, int score) async {
    try {
      final db = await _dbHelper.database;

      // Buscar progresso atual
      final progress = await db.query(
        'game_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (progress.isEmpty) {
        // Criar novo progresso
        await db.insert('game_progress', {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'user_id': userId,
          'level': 1,
          'experience': score,
          'max_score': score,
          'missions_completed': 0,
          'last_played': DateTime.now().toIso8601String(),
        });
      } else {
        // Atualizar progresso existente
        final currentProgress = progress.first;
        final currentMaxScore = currentProgress['max_score'] as int;
        final currentLevel = currentProgress['level'] as int;
        final currentExp = currentProgress['experience'] as int;

        // Calcular novo nível baseado na experiência
        final newExp = currentExp + score;
        final newLevel = _calculateLevel(newExp);

        await db.update(
          'game_progress',
          {
            'experience': newExp,
            'max_score': score > currentMaxScore ? score : currentMaxScore,
            'level': newLevel,
            'last_played': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // Atualizar no Supabase
        await _supabase.from('game_progress').upsert({
          'user_id': userId,
          'experience': newExp,
          'max_score': score > currentMaxScore ? score : currentMaxScore,
          'level': newLevel,
          'last_played': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erro ao atualizar progresso: $e');
      rethrow;
    }
  }

  // Calcular nível baseado na experiência
  int _calculateLevel(int experience) {
    // Fórmula simples: cada 1000 pontos = 1 nível
    return (experience ~/ 1000) + 1;
  }

  // Buscar progresso do jogo
  Future<Map<String, dynamic>> getGameProgress(String userId) async {
    try {
      final db = await _dbHelper.database;
      final progress = await db.query(
        'game_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (progress.isEmpty) {
        return {
          'level': 1,
          'experience': 0,
          'max_score': 0,
          'missions_completed': 0,
        };
      }

      return progress.first;
    } catch (e) {
      print('Erro ao buscar progresso: $e');
      rethrow;
    }
  }

  // Buscar missões
  Future<List<Map<String, dynamic>>> getMissions(String userId) async {
    try {
      final db = await _dbHelper.database;

      // Buscar missões do usuário
      final userMissions = await db.query(
        'user_missions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Buscar detalhes das missões
      final missions = await db.query('missions');

      // Combinar dados
      final List<Map<String, dynamic>> result = [];
      for (var mission in missions) {
        final userMission = userMissions.firstWhere(
          (um) => um['mission_id'] == mission['id'],
          orElse: () => {
            'status': 'pending',
            'started_at': null,
            'completed_at': null,
          },
        );

        result.add({
          ...mission,
          'status': userMission['status'],
          'started_at': userMission['started_at'],
          'completed_at': userMission['completed_at'],
        });
      }

      return result;
    } catch (e) {
      print('Erro ao buscar missões: $e');
      rethrow;
    }
  }

  // Atualizar status da missão
  Future<void> updateMissionStatus({
    required String userId,
    required String missionId,
    required String status,
  }) async {
    try {
      final db = await _dbHelper.database;

      // Atualizar localmente
      await db.insert(
        'user_missions',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'user_id': userId,
          'mission_id': missionId,
          'status': status,
          'started_at':
              status == 'in_progress' ? DateTime.now().toIso8601String() : null,
          'completed_at':
              status == 'completed' ? DateTime.now().toIso8601String() : null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Atualizar no Supabase
      await _supabase.from('user_missions').upsert({
        'user_id': userId,
        'mission_id': missionId,
        'status': status,
        'started_at':
            status == 'in_progress' ? DateTime.now().toIso8601String() : null,
        'completed_at':
            status == 'completed' ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      print('Erro ao atualizar status da missão: $e');
      rethrow;
    }
  }
}
