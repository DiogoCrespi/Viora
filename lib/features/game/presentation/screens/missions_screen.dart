import 'package:flutter/material.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/game/data/repositories/mission_repository.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/presentation/widgets/viora_drawer.dart';
import 'package:viora/routes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MissionsScreen extends StatefulWidget {
  final String userId;

  const MissionsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  late MissionRepository _missionRepository;
  List<Map<String, dynamic>> _missions = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;

  final List<String> _sections = [
    'Dashboard',
    'Missões',
    'Configurações',
  ];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'viora.db'),
        onCreate: (db, version) async {
          // O schema será criado automaticamente pelo InitialSchema
        },
        version: 1,
      );

      _missionRepository = MissionRepository(database);
      await _missionRepository.initializeMissions(widget.userId);
      await _loadMissions();
    } catch (e) {
      print('Erro ao inicializar banco de dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMissions() async {
    try {
      final missions = await _missionRepository.getMissions(widget.userId);
      setState(() {
        _missions = missions;
      });
    } catch (e) {
      print('Erro ao carregar missões: $e');
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
                            if (_selectedFilter != 'all' &&
                                mission['status'] != _selectedFilter) {
                              return const SizedBox.shrink();
                            }
                            return _buildMissionCard(context, mission);
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

  Widget _buildMissionCard(BuildContext context, Map<String, dynamic> mission) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final status = mission['status'] as String;
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = theme.twilightPurple;
        break;
      case 'in_progress':
        statusColor = theme.sunsetOrange;
        break;
      default:
        statusColor = theme.dawnPink;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: theme.primarySurface.withOpacity(0.95),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.sunsetOrange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mission['title'],
                    style: theme.futuristicSubtitle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mission['description'],
              style: theme.futuristicBody,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: theme.sunsetOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${mission['xp_reward']} ${localizations.missionCardXP}',
                      style: TextStyle(
                        color: theme.sunsetOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!isCompleted && !isInProgress)
                  TextButton(
                    onPressed: () => _startMission(mission['id']),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.sunsetOrange,
                    ),
                    child: Text(localizations.missionCardStartButton),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Concluída';
      case 'in_progress':
        return 'Em Progresso';
      default:
        return 'Pendente';
    }
  }

  Future<void> _startMission(String missionId) async {
    try {
      await _missionRepository.updateMissionStatus(
        userId: widget.userId,
        missionId: missionId,
        status: 'in_progress',
      );
      await _loadMissions();
    } catch (e) {
      print('Erro ao iniciar missão: $e');
    }
  }
}
