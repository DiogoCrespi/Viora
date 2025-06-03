import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Container(
        decoration: theme.gradientDecoration,
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
                      'Missões',
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
                    _buildFilterChip(context, 'Todas', true),
                    _buildFilterChip(context, 'Em Progresso', false),
                    _buildFilterChip(context, 'Concluídas', false),
                    _buildFilterChip(context, 'Pendentes', false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de Missões
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildMissionCard(context, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);

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
          // TODO: Implementar filtro
        },
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    final missionStatus = ['Em Progresso', 'Concluída', 'Pendente'];
    final statusColors = [
      theme.sunsetOrange,
      theme.twilightPurple,
      theme.dawnPink
    ];

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
                    'Missão ${index + 1}',
                    style: theme.futuristicSubtitle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors[index % 3].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColors[index % 3],
                      width: 1,
                    ),
                  ),
                  child: Text(
                    missionStatus[index % 3],
                    style: TextStyle(
                      color: statusColors[index % 3],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Descrição da missão ${index + 1}. Esta é uma descrição detalhada da missão que precisa ser realizada.',
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
                      '${(index + 1) * 100} XP',
                      style: TextStyle(
                        color: theme.sunsetOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar ação do botão
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.sunsetOrange,
                  ),
                  child: const Text('Ver Detalhes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
