import 'package:flutter/material.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/game/data/repositories/game_repository.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:provider/provider.dart'; // For UserProvider
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/presentation/widgets/viora_drawer.dart';
import 'package:viora/routes.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // No longer directly needed here
import 'package:viora/features/user/presentation/providers/user_provider.dart'; // Import UserProvider

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final GameRepository _gameRepository = GameRepository();
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String? _userId;

  final List<String> _sections = [
    'Dashboard',
    'Missões',
    'Configurações',
  ];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId != null) {
      _loadMissions();
    }
  }

  Future<void> _loadUserId() async {
    // Assumes UserProvider is available and holds the current user's ID
    // In a real scenario, UserProvider would be more robust in how it provides this.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.currentUser?.id; // Example access

    if (currentUserId == null) {
      if (kDebugMode) {
        debugPrint(
            'MissionsScreen: _loadUserId: User ID is null. Cannot load missions.');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Optionally, set an error message to display to the user
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _userId = currentUserId;
      });
    }
  }

  Future<void> _loadMissions() async {
    if (_userId == null) {
      if (kDebugMode) {
        debugPrint(
            'MissionsScreen: _loadMissions: Aborted because userId is null.');
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        debugPrint(
            'MissionsScreen: _loadMissions: Loading prepared missions for user $_userId');
      }
      // Usando o método getUserMissions que já existe no repositório
      final missions = await _gameRepository.getUserMissions(_userId!);

      if (mounted) {
        setState(() {
          _missions = missions;
          _isLoading = false;
        });
        if (kDebugMode) {
          debugPrint(
              'MissionsScreen: _loadMissions: Loaded ${missions.length} missions.');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'MissionsScreen: _loadMissions: Error loading missions: $e\n$stackTrace');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Optionally, set an error message to display to the user
        });
      }
    }
  }

  void _onSectionSelected(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.status);
        break;
      case 1:
        break;
      case 2:
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
        onSectionSelected: (index) => _onSectionSelected(context, index),
      ),
      body: Container(
        decoration: theme.gradientDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 32,
                        color: theme.sunsetOrange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.missionsTitle,
                        style: theme.futuristicTitle,
                      ),
                    ],
                  ),
                ),

                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, localizations.filterAll, 'all'),
                      _buildFilterChip(context, localizations.filterInProgress,
                          'in_progress'),
                      _buildFilterChip(
                          context, localizations.filterCompleted, 'completed'),
                      _buildFilterChip(
                          context, localizations.filterPending, 'pending'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de Missões
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _missions.length,
                          itemBuilder: (context, index) {
                            final mission = _missions[index];
                            if (_selectedFilter == 'all' ||
                                mission['status'] == _selectedFilter) {
                              return _buildMissionCard(mission);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String filter) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.primaryText : theme.sunsetOrange,
          ),
        ),
        backgroundColor: theme.primarySurface,
        selectedColor: theme.sunsetOrange,
        checkmarkColor: theme.primaryText,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final status = mission['status'] ?? 'available';
    final isCompleted = status == 'completed';
    final requiredLevel = mission['required_level'] ?? 1;
    final xpReward = mission['xp_reward'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mission['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission['description'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nível necessário: $requiredLevel',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Recompensa: $xpReward XP',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'completed':
        color = Colors.green;
        text = 'Concluída';
        break;
      case 'available':
        color = Colors.orange;
        text = 'Disponível';
        break;
      case 'locked':
        color = Colors.grey;
        text = 'Bloqueada';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'Em Progresso';
        break;
      default:
        color = Colors.orange;
        text = 'Disponível';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
