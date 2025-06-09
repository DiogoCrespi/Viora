import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/widgets/futuristic_drawer.dart';
import 'package:viora/presentation/screens/profile/status_screen.dart';
import 'package:viora/presentation/screens/game/missions_screen.dart';
import 'package:viora/presentation/screens/profile/settings_screen.dart';
import 'package:viora/presentation/screens/auth/profile_screen.dart';
import 'package:viora/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, this.selectedIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late int _selectedIndex;

  // final List<String> _sections = ['Status', 'Missões', 'Configurações']; // Will be initialized in build

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _drawerAnimationController.duration = Theme.of(context).themeChangeDuration;
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Added

    final List<String> sections = [
      localizations.mainScreenStatusTab,
      localizations.mainScreenMissionsTab,
      localizations.mainScreenSettingsTab,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          sections[_selectedIndex], // Use localized sections
          style: theme.futuristicTitle,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: FuturisticDrawer(
        selectedIndex: _selectedIndex,
        sections: sections, // Use localized sections
        onSectionSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: theme.gradientDecoration,
        child: _selectedIndex == 0
            ? const StatusScreen()
            : _selectedIndex == 1
                ? const MissionsScreen()
                : _selectedIndex == 2
                    ? const SettingsScreen()
                    : Center(
                        child: Text(
                          // This case should ideally not be reached if selectedIndex is always valid
                          'Conteúdo da seção ${sections[_selectedIndex]}',
                          style: theme.futuristicBody,
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar ação principal
        },
        backgroundColor: theme.sunsetOrange,
        child: const Icon(Icons.add, color: AppTheme.deepBrown),
      ),
    );
  }
}
