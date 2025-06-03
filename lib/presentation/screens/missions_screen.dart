import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.deepBrown, AppTheme.geometricBlack],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      color: AppTheme.metallicGold,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Missões',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.metallicGold,
                                fontWeight: FontWeight.bold,
                              ),
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
                  itemCount: 5, // Exemplo com 5 missões
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.deepBrown : AppTheme.metallicGold,
          ),
        ),
        backgroundColor: AppTheme.geometricBlack,
        selectedColor: AppTheme.metallicGold,
        checkmarkColor: AppTheme.deepBrown,
        onSelected: (bool selected) {
          // TODO: Implementar filtro
        },
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, int index) {
    final missionStatus = ['Em Progresso', 'Concluída', 'Pendente'];
    final statusColors = [AppTheme.metallicGold, Colors.green, Colors.orange];

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AppTheme.agedBeige.withOpacity(0.95),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.metallicGold.withOpacity(0.5),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.deepBrown,
                          fontWeight: FontWeight.bold,
                        ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.deepBrown),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: AppTheme.metallicGold,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 100} XP',
                      style: TextStyle(
                        color: AppTheme.metallicGold,
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
                    foregroundColor: AppTheme.metallicGold,
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
