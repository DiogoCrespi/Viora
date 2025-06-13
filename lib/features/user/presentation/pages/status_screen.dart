import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/game/data/repositories/game_repository.dart';
import 'package:viora/features/game/presentation/pages/space_shooter_game.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/presentation/widgets/viora_drawer.dart';
import 'package:viora/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final GameRepository _gameRepository = GameRepository();
  String? _userId;
  Map<String, dynamic> _gameProgress = {
    'level': 1,
    'experience': 0,
    'max_score': 0,
    'missions_completed': 0,
  };

  final List<String> _sections = [
    'Dashboard',
    'Missões',
    'Configurações',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserIdAndProgress();
  }

  Future<void> _initUserIdAndProgress() async {
    // Tenta pegar o UUID do Supabase
    String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      // Se não autenticado, tenta pegar do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('local_user_id');
      if (userId == null) {
        // Se não existe, gera um novo UUID local
        userId = const Uuid().v4();
        await prefs.setString('local_user_id', userId);
      }
    }
    setState(() {
      _userId = userId;
    });
    _loadGameProgress(userId);
  }

  Future<void> _loadGameProgress(String userId) async {
    try {
      final progress = await _gameRepository.getGameProgress(userId);
      setState(() {
        _gameProgress = progress;
      });
    } catch (e) {
      print('Erro ao carregar progresso: $e');
    }
  }

  void _onSectionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Dashboard
        // Já estamos na tela de status
        break;
      case 1: // Missões
        Navigator.pushNamed(context, AppRoutes.missions);
        break;
      case 2: // Configurações
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: VioraDrawer(
        selectedIndex: _selectedIndex,
        sections: _sections,
        onSectionSelected: _onSectionSelected,
      ),
      body: Container(
        decoration: theme.gradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Conteúdo Principal
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Card de Boas-vindas
                          Card(
                            color: theme.primarySurface.withOpacity(0.95),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: theme.sunsetOrange,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.rocket_launch,
                                    size: 64,
                                    color: theme.sunsetOrange,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    localizations.statusScreenWelcomeTitle,
                                    style: theme.futuristicTitle,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localizations.statusScreenWelcomeSubtitle,
                                    style: theme.futuristicSubtitle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: _userId == null
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    SpaceShooterGame(
                                                        userId: _userId!),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  const begin =
                                                      Offset(1.0, 0.0);
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeInOutCubic;
                                                  var tween = Tween(
                                                    begin: begin,
                                                    end: end,
                                                  ).chain(
                                                      CurveTween(curve: curve));
                                                  var offsetAnimation =
                                                      animation.drive(tween);
                                                  return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child);
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 800),
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.sunsetOrange,
                                      foregroundColor: AppTheme.geometricBlack,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      localizations.playButton,
                                      style: theme.futuristicSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Card de Status do Personagem
                          Card(
                            color: theme.primarySurface.withOpacity(0.8),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: theme.sunsetOrange.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.characterStatusTitle,
                                    style: theme.futuristicSubtitle,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    context,
                                    localizations.levelLabel,
                                    '${_gameProgress['level']}',
                                    Icons.star,
                                  ),
                                  _buildStatRow(
                                    context,
                                    localizations.experienceLabel,
                                    '${_gameProgress['experience']}/${_gameProgress['level'] * 1000}',
                                    Icons.trending_up,
                                  ),
                                  _buildStatRow(
                                    context,
                                    localizations.missionsCompletedLabel,
                                    '${_gameProgress['missions_completed']}',
                                    Icons.assignment_turned_in,
                                  ),
                                  _buildStatRow(
                                    context,
                                    localizations.maxScoreLabel,
                                    '${_gameProgress['max_score']}',
                                    Icons.emoji_events,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryText, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.futuristicBody,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.futuristicSubtitle,
          ),
        ],
      ),
    );
  }
}
