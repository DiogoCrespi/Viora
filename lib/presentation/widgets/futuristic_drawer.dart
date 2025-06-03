import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';

class FuturisticDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<String> sections;
  final Function(int) onSectionSelected;

  const FuturisticDrawer({
    super.key,
    required this.selectedIndex,
    required this.sections,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: theme.brightness == Brightness.light
            ? AppTheme.sunsetGradient
            : AppTheme.nightGradient,
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(
            color: AppTheme.metallicGold,
            height: 1,
            thickness: 0.5,
          ),
          Expanded(child: _buildSections(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.metallicGold.withOpacity(0.1),
            AppTheme.metallicGold.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.metallicGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.metallicGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: AppTheme.metallicGold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viora',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppTheme.metallicGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema de Missões',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSections(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.metallicGold.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.metallicGold.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            selected: isSelected,
            selectedTileColor: Colors.transparent,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.metallicGold.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForIndex(index),
                color: isSelected
                    ? AppTheme.metallicGold
                    : (theme.brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              ),
            ),
            title: Text(
              sections[index],
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? AppTheme.metallicGold
                    : (theme.brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
                letterSpacing: 0.5,
              ),
            ),
            onTap: () => onSectionSelected(index),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.metallicGold.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined,
                color: theme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white),
            onPressed: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_outlined;
      case 1:
        return Icons.assignment_outlined;
      case 2:
        return Icons.settings_outlined;
      default:
        return Icons.error_outline;
    }
  }
}
