import 'package:flutter/material.dart';
import 'package:viora/theme/app_theme.dart';

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
      child: Center(
        child: Card(
          color: AppTheme.agedBeige.withOpacity(0.95),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.metallicGold, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  size: 48,
                  color: AppTheme.metallicGold,
                ),
                const SizedBox(height: 16),
                Text(
                  'Status do Usuário',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aqui você verá um resumo do seu progresso, conquistas e notificações importantes.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.deepBrown),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Espaço para widgets de status futuramente
              ],
            ),
          ),
        ),
      ),
    );
  }
}
