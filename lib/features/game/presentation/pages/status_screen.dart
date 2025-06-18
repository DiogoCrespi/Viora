import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/game/data/repositories/game_repository.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:provider/provider.dart'; // For UserProvider
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/presentation/widgets/viora_drawer.dart';
import 'package:viora/routes.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // No longer directly needed
// import 'package:shared_preferences/shared_preferences.dart'; // No longer directly needed
// import 'package:uuid/uuid.dart'; // No longer directly needed
import 'package:viora/features/user/presentation/providers/user_provider.dart'; // Import UserProvider

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initUserIdAndProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId != null) {
      _loadGameProgress(_userId!);
    }
  }

  Future<void> _initUserIdAndProgress() async {
    // UserProvider is assumed to handle logic for providing a userID (Supabase or local fallback)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.currentUser?.id; // Example access

    if (currentUserId == null) {
      if (kDebugMode) {
        debugPrint(
            'StatusScreen: _initUserIdAndProgress: User ID is null. Cannot load game progress.');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Optionally, set an error message or guide user to login
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _userId = currentUserId;
      });
      // Call _loadGameProgress only if userId is successfully obtained and component is still mounted
      _loadGameProgress(currentUserId);
    }
  }

  Future<void> _loadGameProgress(String userId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        debugPrint(
            'StatusScreen: _loadGameProgress: Loading comprehensive game status for user $userId');
      }

      // Carregar progresso do jogo
      final gameData = await _gameRepository.getUserProgress(userId);

      // Carregar missões do usuário para contar as concluídas
      final userMissions = await _gameRepository.getUserMissions(userId);
      final completedMissions = userMissions
          .where((mission) => mission['status'] == 'completed')
          .length;

      if (mounted) {
        setState(() {
          _gameProgress = {
            'level': gameData['level'] ?? 1,
            'experience': gameData['experience'] ?? 0,
            'max_score': gameData['max_score'] ?? 0,
            'missions_completed': completedMissions,
          };
          _isLoading = false;
        });

        // Atualizar o progresso no banco de dados
        await _gameRepository.updateGameProgress(
          userId,
          gameData['max_score'] ?? 0,
          0, // duration não é relevante aqui
        );

        if (kDebugMode) {
          debugPrint(
              'StatusScreen: _loadGameProgress: Loaded game status successfully.');
          debugPrint('Missões concluídas: $completedMissions');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'StatusScreen: _loadGameProgress: Error loading game progress: $e\n$stackTrace');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                                          localizations
                                              .statusScreenWelcomeTitle,
                                          style: theme.futuristicTitle,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          localizations
                                              .statusScreenWelcomeSubtitle,
                                          style: theme.futuristicSubtitle,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 32),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.game,
                                              arguments: {'userId': _userId},
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.sunsetOrange,
                                            foregroundColor:
                                                AppTheme.geometricBlack,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 48,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
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
                                      color:
                                          theme.sunsetOrange.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
