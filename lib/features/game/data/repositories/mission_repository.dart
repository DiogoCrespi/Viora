import 'package:sqflite/sqflite.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissionRepository {
  final Database _database;
  final SupabaseClient _supabase;

  MissionRepository(this._database) : _supabase = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getMissions(String userId) async {
    try {
      // Primeiro tenta buscar do Supabase
      final response = await _supabase
          .from('missions')
          .select('*, user_missions!inner(*)')
          .eq('user_missions.user_id', userId);

      if (response != null && response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }

      // Se não encontrar no Supabase, busca do SQLite
      final missions = await _database.query(
        'missions',
        where: 'id IN (SELECT mission_id FROM user_missions WHERE user_id = ?)',
        whereArgs: [userId],
      );

      return missions;
    } catch (e) {
      print('Erro ao buscar missões: $e');
      return [];
    }
  }

  Future<void> updateMissionStatus({
    required String userId,
    required String missionId,
    required String status,
  }) async {
    try {
      // Atualiza no Supabase
      await _supabase.from('user_missions').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).match({
        'user_id': userId,
        'mission_id': missionId,
      });

      // Atualiza no SQLite
      await _database.update(
        'user_missions',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND mission_id = ?',
        whereArgs: [userId, missionId],
      );
    } catch (e) {
      print('Erro ao atualizar status da missão: $e');
      rethrow;
    }
  }

  Future<void> initializeMissions(String userId) async {
    try {
      // Verifica se já existem missões para o usuário
      final existingMissions = await _database.query(
        'user_missions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (existingMissions.isNotEmpty) {
        return; // Já existem missões para este usuário
      }

      // Lista de missões iniciais
      final missions = [
        {
          'id': 'mission_1',
          'title': 'Primeiros Passos',
          'description': 'Complete o tutorial do jogo',
          'xp_reward': 100,
          'difficulty_level': 1,
        },
        {
          'id': 'mission_2',
          'title': 'Caçador de Pontos',
          'description': 'Alcance 1000 pontos em uma única partida',
          'xp_reward': 200,
          'difficulty_level': 2,
        },
        {
          'id': 'mission_3',
          'title': 'Mestre do Tempo',
          'description': 'Jogue por 30 minutos consecutivos',
          'xp_reward': 300,
          'difficulty_level': 2,
        },
        {
          'id': 'mission_4',
          'title': 'Colecionador',
          'description': 'Colete 50 itens durante o jogo',
          'xp_reward': 400,
          'difficulty_level': 3,
        },
        {
          'id': 'mission_5',
          'title': 'Lenda do Jogo',
          'description': 'Alcance o nível 10',
          'xp_reward': 500,
          'difficulty_level': 4,
        },
      ];

      // Insere as missões no Supabase
      for (final mission in missions) {
        await _supabase.from('missions').upsert(mission);
        await _supabase.from('user_missions').insert({
          'user_id': userId,
          'mission_id': mission['id'],
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Insere as missões no SQLite
      for (final mission in missions) {
        await _database.insert('missions', mission);
        await _database.insert('user_missions', {
          'user_id': userId,
          'mission_id': mission['id'],
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erro ao inicializar missões: $e');
      rethrow;
    }
  }
}
