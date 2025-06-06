import 'package:flutter/material.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/l10n/app_localizations.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Added

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
                      localizations.missionsTitle, // Localized
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
                    _buildFilterChip(
                        context, localizations.filterAll, true), // Localized
                    _buildFilterChip(context, localizations.filterInProgress,
                        false), // Localized
                    _buildFilterChip(context, localizations.filterCompleted,
                        false), // Localized
                    _buildFilterChip(context, localizations.filterPending,
                        false), // Localized
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
    final localizations = AppLocalizations.of(context)!; // Added

    // It's better to get these from localizations if they need to be translated
    // For now, assuming these specific status strings might be keys themselves or might be handled differently
    // If "Em Progresso", "Concluída", "Pendente" are also in ARB files, they should be fetched.
    // For this iteration, I'll keep them as is, as they were not in the provided ARB additions for mission status.
    final missionStatus = [
      localizations.filterInProgress,
      localizations.filterCompleted,
      localizations.filterPending
    ];
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
                    '${localizations.missionCardTitlePrefix} ${index + 1}', // Localized
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
              '${localizations.missionCardDescriptionPrefix} ${index + 1}. Esta é uma descrição detalhada da missão que precisa ser realizada.', // Localized prefix
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
                      '${(index + 1) * 100} ${localizations.missionCardXP}', // Localized
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
                  child: Text(
                      localizations.missionCardViewDetailsButton), // Localized
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
