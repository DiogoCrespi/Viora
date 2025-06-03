import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/presentation/screens/space_shooter_game.dart';
import 'package:viora/presentation/screens/missions_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepBrown, AppTheme.geometricBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                          color: AppTheme.agedBeige.withOpacity(0.95),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(
                              color: AppTheme.metallicGold,
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
                                  color: AppTheme.metallicGold,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Bem-vindo ao Viora',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                        color: AppTheme.deepBrown,
                                        fontFamily: 'Orbitron',
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Prepare-se para uma jornada espacial épica!',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.deepBrown,
                                        fontFamily: 'Exo2',
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SpaceShooterGame(),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.metallicGold,
                                    foregroundColor: AppTheme.geometricBlack,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'JOGAR',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Orbitron',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Card de Status do Personagem
                        Card(
                          color: AppTheme.geometricBlack.withOpacity(0.8),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: AppTheme.metallicGold.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status do Personagem',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                        color: AppTheme.metallicGold,
                                        fontFamily: 'Orbitron',
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                  context,
                                  'Nível',
                                  '1',
                                  Icons.star,
                                ),
                                _buildStatRow(
                                  context,
                                  'Experiência',
                                  '0/1000',
                                  Icons.trending_up,
                                ),
                                _buildStatRow(
                                  context,
                                  'Missões Concluídas',
                                  '0',
                                  Icons.assignment_turned_in,
                                ),
                                _buildStatRow(
                                  context,
                                  'Pontuação Máxima',
                                  '0',
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
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.agedBeige, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.agedBeige,
                  fontFamily: 'Exo2',
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.metallicGold,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
