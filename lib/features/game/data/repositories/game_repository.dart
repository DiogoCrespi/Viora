import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/core/database/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class GameRepository {
  final DatabaseHelper _dbHelper;
  final SupabaseClient _supabase;

  // Thresholds de nível do jogo
  final Map<int, int> _levelThresholds = {
    1: 0, // Nível 1: Início
    2: 500, // Nível 2: Nebulosa
    3: 1000, // Nível 3: Galáxia
    4: 2000, // Nível 4: Super Nova
    5: 4000, // Nível 5: Buraco Negro
  };

  GameRepository()
      : _dbHelper = DatabaseHelper(),
        _supabase = SupabaseConfig.client;

  // Salvar pontuação do jogo
  Future<void> saveGameScore({
    required String userId,
    required int score,
    required int level,
  }) async {
    try {
      // Verificar se o userId é um UUID válido
      if (!_isValidUUID(userId)) {
        print('UserId inválido: $userId. Usando banco de dados local.');
        await _saveGameScoreLocal(
          userId: userId,
          score: score,
          level: level,
        );
        return;
      }

      // Buscar progresso atual
      final progress = await _supabase
          .from('game_progress')
          .select()
          .eq('user_id', userId)
          .single();

      if (progress == null) {
        // Criar novo progresso
        await _supabase.from('game_progress').insert({
          'user_id': userId,
          'level': level,
          'experience': score,
          'max_score': score,
          'missions_completed': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Atualizar progresso existente
        final currentXp = progress['experience'] as int;
        final currentMaxScore = progress['max_score'] as int;

        // Calcular novo XP e nível
        final newXp = currentXp + score;
        final newLevel = _calculateLevel(newXp);
        final newMaxScore = score > currentMaxScore ? score : currentMaxScore;

        await _supabase.from('game_progress').update({
          'level': newLevel,
          'experience': newXp,
          'max_score': newMaxScore,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      }

      // Verificar e atualizar missões
      await checkAndUpdateMissions(
        userId: userId,
        score: score,
        level: level,
      );
    } catch (e) {
      print('Erro ao salvar pontuação: $e');
      // Em caso de erro no Supabase, usar SQLite local
      await _saveGameScoreLocal(
        userId: userId,
        score: score,
        level: level,
      );
    }
  }

  // Salvar pontuação do jogo localmente (SQLite)
  Future<void> _saveGameScoreLocal({
    required String userId,
    required int score,
    required int level,
  }) async {
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
          'user_id': userId,
          'level': level,
          'experience': score,
          'max_score': score,
          'missions_completed': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Atualizar progresso existente
        final currentProgress = progress.first;
        final currentXp = currentProgress['experience'] as int;
        final currentMaxScore = currentProgress['max_score'] as int;

        // Calcular novo XP e nível
        final newXp = currentXp + score;
        final newLevel = _calculateLevel(newXp);
        final newMaxScore = score > currentMaxScore ? score : currentMaxScore;

        await db.update(
          'game_progress',
          {
            'level': newLevel,
            'experience': newXp,
            'max_score': newMaxScore,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }

      // Verificar e atualizar missões
      await _checkAndUpdateMissionsLocal(
        userId: userId,
        score: score,
        level: level,
      );
    } catch (e) {
      print('Erro ao salvar pontuação localmente: $e');
      rethrow;
    }
  }

  // Calcular XP baseado na pontuação
  int _calculateXpForScore(int score) {
    // Fórmula simples: XP = score * 2
    return score * 2;
  }

  // Atualizar progresso do jogo
  Future<void> updateGameProgress(
      String userId, int score, int duration) async {
    try {
      // Primeiro tenta atualizar no Supabase
      try {
        final currentProgress = await getUserProgress(userId);
        final currentLevel = currentProgress['level'] as int;
        final currentExp = currentProgress['experience'] as int;
        final currentMaxScore = currentProgress['max_score'] as int? ?? 0;

        // Calcula XP baseado na pontuação
        final xpGained = _calculateXpForScore(score);
        final newExp = currentExp + xpGained;
        final newLevel = _calculateLevel(newExp);

        // Atualiza o progresso
        await _supabase.from('game_progress').upsert({
          'user_id': userId,
          'level': newLevel,
          'experience': newExp,
          'max_score': score > currentMaxScore ? score : currentMaxScore,
          'last_played': DateTime.now().toIso8601String(),
        });

        // Verifica e atualiza missões após atualizar o progresso
        await checkAndUpdateMissions(
          userId: userId,
          score: score,
          level: newLevel,
        );
      } catch (e) {
        print('Erro ao atualizar progresso no Supabase: $e');
        // Continua para atualizar no SQLite
      }

      // Atualiza no SQLite
      final db = await _dbHelper.database;
      final currentProgress = await getUserProgress(userId);
      final currentLevel = currentProgress['level'] as int;
      final currentExp = currentProgress['experience'] as int;
      final currentMaxScore = currentProgress['max_score'] as int? ?? 0;

      // Calcula XP baseado na pontuação
      final xpGained = _calculateXpForScore(score);
      final newExp = currentExp + xpGained;
      final newLevel = _calculateLevel(newExp);

      await db.insert(
        'game_progress',
        {
          'user_id': userId,
          'level': newLevel,
          'experience': newExp,
          'max_score': score > currentMaxScore ? score : currentMaxScore,
          'last_played': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Verifica e atualiza missões no SQLite
      await _checkAndUpdateMissionsLocal(
        userId: userId,
        score: score,
        level: newLevel,
      );
    } catch (e) {
      print('Erro ao atualizar progresso do jogo: $e');
      rethrow;
    }
  }

  // Calcular nível com base no XP
  int _calculateLevel(int xp) {
    // Fórmula simples: nível = raiz quadrada do XP / 10
    return (sqrt(xp) / 10).floor() + 1;
  }

  // Obter progresso do usuário
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      // Verificar se o userId é um UUID válido
      if (_isValidUUID(userId)) {
        try {
          // Buscar progresso do usuário
          final response = await _supabase
              .from('game_progress')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .single();

          if (response != null) {
            // Buscar missões concluídas
            final completedMissions = await _supabase
                .from('user_missions')
                .select()
                .eq('user_id', userId)
                .eq('status', 'completed');

            final missionsCompleted = completedMissions.length;

            // Atualizar o contador de missões concluídas
            await _supabase.from('game_progress').update({
              'missions_completed': missionsCompleted,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('user_id', userId);

            return {
              'level': response['level'] ?? 1,
              'experience': response['experience'] ?? 0,
              'max_score': response['max_score'] ?? 0,
              'missions_completed': missionsCompleted,
              'last_played': response['last_played'],
            };
          }
        } catch (e) {
          print('Erro ao buscar progresso do usuário: $e');
          // Continua para buscar do SQLite
        }
      }

      // Se não encontrar no Supabase ou userId não é UUID, busca do SQLite
      return _getUserProgressLocal(userId);
    } catch (e) {
      print('Erro ao buscar progresso do usuário: $e');
      return {
        'level': 1,
        'experience': 0,
        'max_score': 0,
        'missions_completed': 0,
        'last_played': null,
      };
    }
  }

  // Obter progresso do usuário localmente (SQLite)
  Future<Map<String, dynamic>> _getUserProgressLocal(String userId) async {
    print(
        '_getUserProgressLocal: Iniciando busca de progresso local para usuário $userId');

    if (!_isValidUUID(userId)) {
      print('_getUserProgressLocal: ID de usuário inválido: $userId');
      return {
        'level': 1,
        'experience': 0,
        'max_score': 0,
        'missions_completed': 0,
        'last_played': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };
    }

    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'game_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      print(
          '_getUserProgressLocal: Encontrados ${results.length} registros de progresso');

      if (results.isEmpty) {
        print(
            '_getUserProgressLocal: Nenhum progresso encontrado, criando novo');
        // Criar novo progresso
        final now = DateTime.now().toIso8601String();
        final newProgress = {
          'id': const Uuid().v4(),
          'user_id': userId,
          'level': 1,
          'experience': 0,
          'max_score': 0,
          'missions_completed': 0,
          'last_played': now,
          'created_at': now,
          'updated_at': now
        };

        try {
          await db.insert('game_progress', newProgress);
          print('_getUserProgressLocal: Novo progresso criado com sucesso');
          return newProgress;
        } catch (e) {
          print('_getUserProgressLocal: Erro ao criar novo progresso: $e');
          // Tentar inserir sem as colunas de timestamp
          final fallbackProgress = {
            'id': const Uuid().v4(),
            'user_id': userId,
            'level': 1,
            'experience': 0,
            'max_score': 0,
            'missions_completed': 0,
            'last_played': now
          };
          await db.insert('game_progress', fallbackProgress);
          print('_getUserProgressLocal: Novo progresso criado com fallback');
          return fallbackProgress;
        }
      }

      // Buscar missões concluídas
      final completedMissions = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM user_missions
        WHERE user_id = ? AND status = 'completed'
      ''', [userId]);

      final missionsCompleted = completedMissions.first['count'] as int;

      // Atualizar o contador de missões concluídas
      await db.update(
        'game_progress',
        {
          'missions_completed': missionsCompleted,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final progress = results.first;
      progress['missions_completed'] = missionsCompleted;

      return progress;
    } catch (e) {
      print('_getUserProgressLocal: Erro ao buscar progresso local: $e');
      return {
        'level': 1,
        'experience': 0,
        'max_score': 0,
        'missions_completed': 0,
        'last_played': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };
    }
  }

  // Obter missões do usuário
  Future<List<Map<String, dynamic>>> getUserMissions(String userId) async {
    try {
      print('Buscando missões do usuário: $userId');

      // Verificar se o userId é um UUID válido
      if (_isValidUUID(userId)) {
        try {
          // Buscar missões do usuário com detalhes
          final response = await _supabase
              .from('user_missions')
              .select('*, missions!inner(*)')
              .eq('user_id', userId)
              .order('missions(required_level)', ascending: true);

          print('Missões encontradas no Supabase: ${response.length}');

          if (response.isEmpty) {
            print(
                'Nenhuma missão encontrada no Supabase, inicializando missões');
            // Inicializar missões para o usuário
            await initializeMissions(userId);

            // Buscar novamente após inicialização
            final missionsAfterInit = await _supabase
                .from('user_missions')
                .select('*, missions!inner(*)')
                .eq('user_id', userId)
                .order('missions(required_level)', ascending: true);

            print('Missões após inicialização: ${missionsAfterInit.length}');

            // Mapear para o formato esperado
            return missionsAfterInit.map((mission) {
              return {
                'id': mission['id'],
                'mission_id': mission['mission_id'],
                'status': mission['status'],
                'title': mission['missions']['title'],
                'description': mission['missions']['description'],
                'type': mission['missions']['type'],
                'required_score': mission['missions']['required_score'],
                'required_level': mission['missions']['required_level'],
                'xp_reward': mission['missions']['xp_reward'],
                'created_at': mission['created_at'],
                'updated_at': mission['updated_at'],
              };
            }).toList();
          }

          // Mapear para o formato esperado
          return response.map((mission) {
            return {
              'id': mission['id'],
              'mission_id': mission['mission_id'],
              'status': mission['status'],
              'title': mission['missions']['title'],
              'description': mission['missions']['description'],
              'type': mission['missions']['type'],
              'required_score': mission['missions']['required_score'],
              'required_level': mission['missions']['required_level'],
              'xp_reward': mission['missions']['xp_reward'],
              'created_at': mission['created_at'],
              'updated_at': mission['updated_at'],
            };
          }).toList();
        } catch (e) {
          print('Erro ao buscar missões do Supabase: $e');
          // Continua para buscar do SQLite
        }
      }

      // Se não encontrar no Supabase ou userId não é UUID, busca do SQLite
      return _getUserMissionsLocal(userId);
    } catch (e) {
      print('Erro ao buscar missões do usuário: $e');
      return _getUserMissionsLocal(userId);
    }
  }

  // Obter missões do usuário localmente (SQLite)
  Future<List<Map<String, dynamic>>> _getUserMissionsLocal(
      String userId) async {
    try {
      print('Buscando missões locais para o usuário: $userId');
      final db = await _dbHelper.database;

      // Buscar todas as missões do usuário com detalhes
      final userMissions = await db.rawQuery('''
        SELECT um.*, m.*
        FROM user_missions um
        JOIN missions m ON um.mission_id = m.id
        WHERE um.user_id = ?
        ORDER BY m.required_level
      ''', [userId]);

      print('Missões locais encontradas: ${userMissions.length}');

      if (userMissions.isEmpty) {
        print('Nenhuma missão local encontrada, inicializando missões');
        // Inicializar missões para o usuário
        await _initializeMissionsLocal(userId);

        // Buscar novamente após inicialização
        final missionsAfterInit = await db.rawQuery('''
          SELECT um.*, m.*
          FROM user_missions um
          JOIN missions m ON um.mission_id = m.id
          WHERE um.user_id = ?
          ORDER BY m.required_level
        ''', [userId]);

        print('Missões locais após inicialização: ${missionsAfterInit.length}');

        // Mapear para o formato esperado
        return missionsAfterInit.map((mission) {
          return {
            'id': mission['id'],
            'mission_id': mission['mission_id'],
            'status': mission['status'],
            'title': mission['title'],
            'description': mission['description'],
            'type': mission['type'] ?? _determineMissionType(mission),
            'required_score':
                mission['required_score'] ?? _determineRequiredScore(mission),
            'required_level': mission['required_level'],
            'xp_reward': mission['xp_reward'],
            'created_at': mission['created_at'],
            'updated_at': mission['updated_at'],
          };
        }).toList();
      }

      // Mapear para o formato esperado
      return userMissions.map((mission) {
        return {
          'id': mission['id'],
          'mission_id': mission['mission_id'],
          'status': mission['status'],
          'title': mission['title'],
          'description': mission['description'],
          'type': mission['type'] ?? _determineMissionType(mission),
          'required_score':
              mission['required_score'] ?? _determineRequiredScore(mission),
          'required_level': mission['required_level'],
          'xp_reward': mission['xp_reward'],
          'created_at': mission['created_at'],
          'updated_at': mission['updated_at'],
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar missões do usuário localmente: $e');
      // Retorna uma lista vazia em caso de erro
      return [];
    }
  }

  // Buscar missões
  Future<List<Map<String, dynamic>>> getMissions(String userId) async {
    try {
      // Verificar se o userId é um UUID válido
      if (_isValidUUID(userId)) {
        // Primeiro tenta buscar do Supabase
        try {
          final response = await _supabase
              .from('user_missions')
              .select('*, missions!inner(*)')
              .eq('user_id', userId)
              .order('missions.required_level', ascending: true);

          if (response != null && response.isNotEmpty) {
            return response.map((mission) {
              return {
                'id': mission['mission_id'],
                'title': mission['missions']['title'],
                'description': mission['missions']['description'],
                'type': mission['missions']['type'],
                'required_score': mission['missions']['required_score'],
                'required_level': mission['missions']['required_level'],
                'xp_reward': mission['missions']['xp_reward'],
                'created_at': mission['created_at'],
                'updated_at': mission['updated_at'],
                'status': mission['status'],
              };
            }).toList();
          }
        } catch (e) {
          print('Erro ao buscar missões do Supabase: $e');
          // Continua para buscar do SQLite
        }
      }

      // Se não encontrar no Supabase ou userId não é UUID, busca do SQLite
      final db = await _dbHelper.database;

      // Buscar missões e status do usuário
      final missions = await db.query('missions', orderBy: 'required_level');
      final userMissions = await db.query(
        'user_missions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Mapear status das missões
      final Map<String, String> missionStatus = {};
      for (var userMission in userMissions) {
        missionStatus[userMission['mission_id'] as String] =
            userMission['status'] as String;
      }

      // Combinar informações e mapear campos para corresponder ao formato do Supabase
      final result = missions.map((mission) {
        final missionId = mission['id'] as String;

        // Mapear campos do SQLite para o formato do Supabase
        return {
          'id': mission['id'],
          'title': mission['title'],
          'description': mission['description'],
          'type': _determineMissionType(mission),
          'required_score': _determineRequiredScore(mission),
          'required_level': mission['required_level'],
          'xp_reward': mission['xp_reward'],
          'created_at': mission['created_at'],
          'updated_at': mission['updated_at'],
          'status': missionStatus[missionId] ?? 'available',
        };
      }).toList();

      return result;
    } catch (e) {
      print('Erro ao buscar missões: $e');
      // Em caso de erro, retorna lista vazia
      return [];
    }
  }

  // Determina o tipo da missão com base na descrição
  String _determineMissionType(Map<String, dynamic> mission) {
    final description = mission['description'] as String;
    if (description.contains('pontos')) {
      return 'score';
    } else if (description.contains('nível')) {
      return 'level';
    } else {
      return 'score'; // Padrão
    }
  }

  // Determina a pontuação necessária com base na descrição
  int _determineRequiredScore(Map<String, dynamic> mission) {
    final description = mission['description'] as String;
    if (description.contains('100 pontos')) {
      return 100;
    } else if (description.contains('500 pontos')) {
      return 500;
    } else if (description.contains('1000 pontos')) {
      return 1000;
    } else {
      return 0; // Para missões de nível
    }
  }

  // Atualizar status da missão
  Future<void> updateMissionStatus({
    required String userId,
    required String missionId,
    required String status,
  }) async {
    // Atualiza localmente
    final db = await _dbHelper.database;
    await db.insert(
      'user_missions',
      {
        'user_id': userId,
        'mission_id': missionId,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Tenta atualizar no Supabase
    try {
      await _supabase.from('user_missions').upsert({
        'user_id': userId,
        'mission_id': missionId,
        'status': status,
      });
    } catch (e) {
      print('Erro ao atualizar status da missão no Supabase: $e');
      // Continua mesmo com erro no Supabase
    }
  }

  // Inicializar missões para um usuário
  Future<void> initializeMissions(String userId) async {
    try {
      print('Inicializando missões para o usuário: $userId');

      // Verificar se o userId é um UUID válido
      if (!_isValidUUID(userId)) {
        print(
            'ID de usuário inválido para Supabase: $userId. Usando SQLite local.');
        await _initializeMissionsLocal(userId);
        return;
      }

      // Verificar se já existem missões
      final existingMissions =
          await _supabase.from('missions').select().limit(1);

      print('Missões existentes: ${existingMissions.length}');

      if (existingMissions.isEmpty) {
        print('Criando missões padrão no Supabase');
        // Criar missões padrão com IDs fixos
        final defaultMissions = [
          {
            'id': '00000000-0000-0000-0000-000000000001',
            'title': 'Primeiros Passos',
            'description': 'Alcance 100 pontos em uma partida',
            'type': 'score',
            'required_score': 100,
            'required_level': 1,
            'xp_reward': 50,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '00000000-0000-0000-0000-000000000002',
            'title': 'Iniciante',
            'description': 'Alcance 500 pontos em uma partida',
            'type': 'score',
            'required_score': 500,
            'required_level': 1,
            'xp_reward': 100,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '00000000-0000-0000-0000-000000000003',
            'title': 'Intermediário',
            'description': 'Alcance o nível 2',
            'type': 'level',
            'required_score': 0,
            'required_level': 2,
            'xp_reward': 150,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '00000000-0000-0000-0000-000000000004',
            'title': 'Avançado',
            'description': 'Alcance 1000 pontos em uma partida',
            'type': 'score',
            'required_score': 1000,
            'required_level': 2,
            'xp_reward': 200,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '00000000-0000-0000-0000-000000000005',
            'title': 'Mestre',
            'description': 'Alcance o nível 3',
            'type': 'level',
            'required_score': 0,
            'required_level': 3,
            'xp_reward': 300,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        // Inserir missões
        for (var mission in defaultMissions) {
          try {
            final result = await _supabase
                .from('missions')
                .insert(mission)
                .select()
                .single();

            print('Missão criada: ${result['id']}');

            // Criar entrada na tabela user_missions
            await _supabase.from('user_missions').insert({
              'user_id': userId,
              'mission_id': result['id'],
              'status': mission == defaultMissions.first ? 'available' : 'locked',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });

            print(
                'Entrada de user_missions criada para missão: ${result['id']}');
          } catch (e) {
            print('Erro ao criar missão: $e');
            // Continua para a próxima missão
          }
        }
      } else {
        // Verificar se o usuário já tem missões
        final userMissions = await _supabase
            .from('user_missions')
            .select()
            .eq('user_id', userId)
            .limit(1);

        print('Missões do usuário: ${userMissions.length}');

        if (userMissions.isEmpty) {
          print('Criando entradas de user_missions para o usuário');
          // Buscar todas as missões
          final missions =
              await _supabase.from('missions').select().order('required_level');

          print('Total de missões encontradas: ${missions.length}');

          // Criar entradas na tabela user_missions para cada missão
          for (var i = 0; i < missions.length; i++) {
            try {
              final mission = missions[i];
              await _supabase.from('user_missions').insert({
                'user_id': userId,
                'mission_id': mission['id'],
                'status': i == 0 ? 'available' : 'locked',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });

              print(
                  'Entrada de user_missions criada para missão: ${mission['id']}');
            } catch (e) {
              print('Erro ao criar entrada de user_missions: $e');
              // Continua para a próxima missão
            }
          }
        } else {
          print('Usuário já possui missões');
        }
      }

      print('Inicialização de missões concluída com sucesso');
    } catch (e) {
      print('Erro ao inicializar missões no Supabase: $e');
      // Em caso de erro no Supabase, usar SQLite local
      await _initializeMissionsLocal(userId);
    }
  }

  // Inicializar missões localmente (SQLite)
  Future<void> _initializeMissionsLocal(String userId) async {
    try {
      print('Inicializando missões localmente para o usuário: $userId');
      final db = await _dbHelper.database;

      // Verifica se já existem missões
      final missions = await db.query('missions');
      print('Missões existentes no banco local: ${missions.length}');

      if (missions.isEmpty) {
        print('Criando missões padrão no banco local');
        // Cria as missões padrão
        final defaultMissions = [
          {
            'id': 'mission_1',
            'title': 'Primeiros Passos',
            'description': 'Alcance 100 pontos em uma partida',
            'type': 'score',
            'required_score': 100,
            'required_level': 1,
            'xp_reward': 50,
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
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        // Insere as missões
        for (var mission in defaultMissions) {
          try {
            await db.insert('missions', mission);
            print('Missão local criada: ${mission['id']}');
          } catch (e) {
            print('Erro ao inserir missão local: $e');
            // Tenta inserir sem a coluna difficulty_level
            try {
              final missionWithoutDifficulty =
                  Map<String, dynamic>.from(mission);
              missionWithoutDifficulty.remove('difficulty_level');
              await db.insert('missions', missionWithoutDifficulty);
              print(
                  'Missão local criada (sem difficulty_level): ${mission['id']}');
            } catch (e2) {
              print('Erro ao inserir missão local (sem difficulty_level): $e2');
              // Continua para a próxima missão
            }
          }
        }
      }

      // Verifica se o usuário já tem missões
      final userMissions = await db.query(
        'user_missions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      print('Missões do usuário no banco local: ${userMissions.length}');

      if (userMissions.isEmpty) {
        print(
            'Criando entradas de user_missions para o usuário no banco local');
        // Cria as missões do usuário
        final missions = await db.query('missions');
        print(
            'Total de missões encontradas no banco local: ${missions.length}');

        for (var i = 0; i < missions.length; i++) {
          final currentMission = missions[i];
          try {
            await db.insert('user_missions', {
              'id': 'user_mission_${currentMission['id']}_$userId',
              'user_id': userId,
              'mission_id': currentMission['id'],
              'status': i == 0 ? 'available' : 'locked',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            print(
                'Entrada de user_missions local criada para missão: ${currentMission['id']}');
          } catch (e) {
            print('Erro ao criar entrada de user_missions local: $e');
            // Tenta inserir sem a coluna id
            try {
              await db.insert('user_missions', {
                'user_id': userId,
                'mission_id': currentMission['id'],
                'status': i == 0 ? 'available' : 'locked',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
              print(
                  'Entrada de user_missions local criada (sem id): ${currentMission['id']}');
            } catch (e2) {
              print(
                  'Erro ao criar entrada de user_missions local (sem id): $e2');
              // Continua para a próxima missão
            }
          }
        }
      } else {
        print('Usuário já possui missões no banco local');
      }

      print('Inicialização de missões local concluída com sucesso');
    } catch (e) {
      print('Erro ao inicializar missões localmente: $e');
      // Não relançar o erro para evitar interromper o fluxo do jogo
    }
  }

  Future<void> _insertDefaultMissions(Database db) async {
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
      await db.insert('missions', mission);
    }
  }

  /// Força a migração do banco de dados
  Future<void> forceDatabaseMigration() async {
    try {
      await _dbHelper.forceMigration();
      debugPrint('Database migration forced successfully');
    } catch (e) {
      debugPrint('Error forcing database migration: $e');
    }
  }

  // Verificar e atualizar missões
  Future<void> checkAndUpdateMissions({
    required String userId,
    required int score,
    required int level,
  }) async {
    try {
      print('Verificando e atualizando missões para o usuário: $userId');
      print('Score atual: $score, Nível atual: $level');

      // Verificar se o userId é um UUID válido
      if (_isValidUUID(userId)) {
        try {
          // Buscar missões do usuário
          final userMissions = await _supabase
              .from('user_missions')
              .select('*, missions!inner(*)')
              .eq('user_id', userId)
              .order('missions(required_level)', ascending: true);

          print('Missões encontradas: ${userMissions.length}');

          if (userMissions.isEmpty) {
            print('Nenhuma missão encontrada, inicializando missões');
            await initializeMissions(userId);
            return;
          }

          int completedMissionsCount = 0;

          // Atualizar status das missões
          for (var mission in userMissions) {
            final missionData = mission['missions'];
            var currentStatus = mission['status'];
            final requiredLevel = missionData['required_level'];
            final requiredScore = missionData['required_score'];
            final missionId = mission['id'];

            print('Verificando missão: ${missionData['title']}');
            print('Status atual: $currentStatus');
            print('Nível necessário: $requiredLevel');
            print('Score necessário: $requiredScore');

            // Se a missão já está concluída, incrementar contador
            if (currentStatus == 'completed') {
              completedMissionsCount++;
              print('Missão já concluída, pulando');
              continue;
            }

            // Se o nível atual é maior ou igual ao nível necessário, desbloquear a missão
            if (level >= requiredLevel && currentStatus == 'locked') {
              print('Desbloqueando missão: ${missionData['title']}');
              await _supabase
                  .from('user_missions')
                  .update({'status': 'available'}).eq('id', missionId);
              print('Missão desbloqueada com sucesso');
            }

            // Verificar se a missão foi concluída
            if (level >= requiredLevel &&
                score >= requiredScore &&
                currentStatus != 'completed') {
              print('Concluindo missão: ${missionData['title']}');
              await _supabase
                  .from('user_missions')
                  .update({'status': 'completed'}).eq('id', missionId);
              print('Missão concluída com sucesso');
              completedMissionsCount++;

              // Adicionar XP ao usuário
              final xpReward = missionData['xp_reward'];
              print('Adicionando $xpReward XP ao usuário');
              await _updateUserProgress(
                userId: userId,
                xp: xpReward,
              );
            }
          }

          // Atualizar o contador de missões concluídas no progresso do usuário
          await _supabase.from('game_progress').update({
            'missions_completed': completedMissionsCount,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);

          print('Total de missões concluídas: $completedMissionsCount');
        } catch (e) {
          print('Erro ao atualizar missões no Supabase: $e');
          // Continua para atualizar localmente
        }
      }

      // Se não conseguir atualizar no Supabase ou userId não é UUID, atualiza localmente
      await _checkAndUpdateMissionsLocal(
        userId: userId,
        score: score,
        level: level,
      );
    } catch (e) {
      print('Erro ao verificar e atualizar missões: $e');
      // Tenta atualizar localmente em caso de erro
      await _checkAndUpdateMissionsLocal(
        userId: userId,
        score: score,
        level: level,
      );
    }
  }

  // Verificar se uma string é um UUID válido
  bool _isValidUUID(String uuid) {
    // Verificar se o UUID é válido
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // Calcular XP necessário para um nível
  int _getRequiredXpForLevel(int level) {
    // Fórmula simplificada: 1000 * level
    return 1000 * level;
  }

  Future<void> _updateUserProgress({
    required String userId,
    required int xp,
  }) async {
    try {
      print('Atualizando progresso do usuário: $userId');
      print('XP a adicionar: $xp');

      // Verificar se o userId é um UUID válido
      if (_isValidUUID(userId)) {
        try {
          // Buscar progresso atual do usuário
          final progress = await _supabase
              .from('game_progress')
              .select()
              .eq('user_id', userId)
              .single();

          print('Progresso atual encontrado: ${progress != null}');

          if (progress == null) {
            print('Nenhum progresso encontrado, criando novo');
            // Criar novo progresso
            await _supabase.from('game_progress').insert({
              'user_id': userId,
              'level': 1,
              'experience': xp,
              'missions_completed': 0,
              'max_score': 0,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            return;
          }

          // Calcular novo XP e nível
          final currentXp = progress['experience'] as int;
          final currentLevel = progress['level'] as int;
          final newXp = currentXp + xp;
          final requiredXp = _getRequiredXpForLevel(currentLevel);
          var newLevel = currentLevel;

          print('XP atual: $currentXp');
          print('Nível atual: $currentLevel');
          print('Novo XP: $newXp');
          print('XP necessário para o nível atual: $requiredXp');

          // Verificar se subiu de nível
          if (newXp >= requiredXp) {
            newLevel++;
            print('Subiu para o nível $newLevel');
          }

          // Contar missões concluídas
          final completedMissions = await _supabase
              .from('user_missions')
              .select()
              .eq('user_id', userId)
              .eq('status', 'completed');

          final missionsCompleted = completedMissions.length;
          print('Missões concluídas: $missionsCompleted');

          // Atualizar progresso
          await _supabase.from('game_progress').update({
            'level': newLevel,
            'experience': newXp,
            'missions_completed': missionsCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);

          print('Progresso atualizado com sucesso');
        } catch (e) {
          print('Erro ao atualizar progresso no Supabase: $e');
          // Continua para atualizar localmente
        }
      }

      // Se não conseguir atualizar no Supabase ou userId não é UUID, atualiza localmente
      await _updateUserProgressLocal(
        userId: userId,
        xp: xp,
      );
    } catch (e) {
      print('Erro ao atualizar progresso: $e');
      // Tenta atualizar localmente em caso de erro
      await _updateUserProgressLocal(
        userId: userId,
        xp: xp,
      );
    }
  }

  // Atualizar progresso do usuário localmente (SQLite)
  Future<void> _updateUserProgressLocal({
    required String userId,
    required int xp,
  }) async {
    try {
      print('Atualizando progresso local do usuário: $userId');
      print('XP a adicionar: $xp');

      final db = await _dbHelper.database;

      // Buscar progresso atual do usuário
      final progress = await db.query(
        'game_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      print('Progresso local encontrado: ${progress.isNotEmpty}');

      if (progress.isEmpty) {
        print('Nenhum progresso local encontrado, criando novo');
        // Criar novo progresso
        await db.insert('game_progress', {
          'user_id': userId,
          'level': 1,
          'experience': xp,
          'missions_completed': 0,
          'max_score': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return;
      }

      // Calcular novo XP e nível
      final currentXp = progress.first['experience'] as int;
      final currentLevel = progress.first['level'] as int;
      final newXp = currentXp + xp;
      final requiredXp = _getRequiredXpForLevel(currentLevel);
      var newLevel = currentLevel;

      print('XP atual: $currentXp');
      print('Nível atual: $currentLevel');
      print('Novo XP: $newXp');
      print('XP necessário para o nível atual: $requiredXp');

      // Verificar se subiu de nível
      if (newXp >= requiredXp) {
        newLevel++;
        print('Subiu para o nível $newLevel');
      }

      // Contar missões concluídas
      final completedMissions = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM user_missions
        WHERE user_id = ? AND status = 'completed'
      ''', [userId]);

      final missionsCompleted = completedMissions.first['count'] as int;
      print('Missões concluídas: $missionsCompleted');

      // Atualizar progresso
      await db.update(
        'game_progress',
        {
          'level': newLevel,
          'experience': newXp,
          'missions_completed': missionsCompleted,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      print('Progresso local atualizado com sucesso');
    } catch (e) {
      print('Erro ao atualizar progresso local: $e');
    }
  }

  // Verificar e atualizar missões localmente (SQLite)
  Future<void> _checkAndUpdateMissionsLocal({
    required String userId,
    required int score,
    required int level,
  }) async {
    try {
      print('Verificando e atualizando missões locais para o usuário: $userId');
      final db = await _dbHelper.database;

      // Buscar missões do usuário
      final userMissions = await db.rawQuery('''
        SELECT um.*, m.*
        FROM user_missions um
        JOIN missions m ON um.mission_id = m.id
        WHERE um.user_id = ?
        ORDER BY m.required_level
      ''', [userId]);

      if (userMissions.isEmpty) {
        print('Nenhuma missão local encontrada, inicializando missões');
        await _initializeMissionsLocal(userId);
        return;
      }

      int completedMissionsCount = 0;

      // Atualizar status das missões
      for (var mission in userMissions) {
        final missionId = mission['mission_id'] as String;
        var currentStatus = mission['status'] as String;
        final requiredLevel = mission['required_level'] as int;
        final requiredScore = mission['required_score'] as int;

        // Se a missão já está concluída, incrementar contador
        if (currentStatus == 'completed') {
          completedMissionsCount++;
          continue;
        }

        // Se o nível atual é maior ou igual ao nível necessário, desbloquear a missão
        if (level >= requiredLevel &&
            (currentStatus == 'locked' || currentStatus == 'pending')) {
          await db.update(
            'user_missions',
            {'status': 'available'},
            where: 'user_id = ? AND mission_id = ?',
            whereArgs: [userId, missionId],
          );
        }

        // Verificar se a missão foi concluída
        if (level >= requiredLevel &&
            score >= requiredScore &&
            currentStatus != 'completed') {
          await db.update(
            'user_missions',
            {'status': 'completed'},
            where: 'user_id = ? AND mission_id = ?',
            whereArgs: [userId, missionId],
          );
          completedMissionsCount++;

          // Adicionar XP ao usuário
          final xpReward = mission['xp_reward'] as int;
          await _updateUserProgressLocal(
            userId: userId,
            xp: xpReward,
          );
        }
      }

      // Atualizar o contador de missões concluídas no progresso do usuário
      await db.update(
        'game_progress',
        {
          'missions_completed': completedMissionsCount,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      print('Total de missões concluídas localmente: $completedMissionsCount');
    } catch (e) {
      print('Erro ao verificar e atualizar missões localmente: $e');
    }
  }
}
