import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/screens/space_shooter_game.dart';
// import 'package:viora/presentation/screens/missions_screen.dart'; // Not directly used
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Added

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Added

    return Container(
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
                                  localizations.statusScreenWelcomeTitle, // Localized
                                  style: theme.futuristicTitle,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.statusScreenWelcomeSubtitle, // Localized
                                  style: theme.futuristicSubtitle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const SpaceShooterGame(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOutCubic;
                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          var offsetAnimation =
                                              animation.drive(tween);
                                          return SlideTransition(
                                              position: offsetAnimation,
                                              child: child);
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 800),
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
                                    localizations.playButton, // Localized
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
                                  localizations.characterStatusTitle, // Localized
                                  style: theme.futuristicSubtitle,
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                  context,
                                  localizations.levelLabel, // Localized
                                  '1', // Value remains dynamic
                                  Icons.star,
                                ),
                                _buildStatRow(
                                  context,
                                  localizations.experienceLabel, // Localized
                                  '0/1000', // Value remains dynamic
                                  Icons.trending_up,
                                ),
                                _buildStatRow(
                                  context,
                                  localizations.missionsCompletedLabel, // Localized
                                  '0', // Value remains dynamic
                                  Icons.assignment_turned_in,
                                ),
                                _buildStatRow(
                                  context,
                                  localizations.maxScoreLabel, // Localized
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
