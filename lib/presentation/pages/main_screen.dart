import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/widgets/viora_drawer.dart';
import 'package:viora/features/game/presentation/pages/status_screen.dart';
import 'package:viora/features/game/presentation/pages/missions_screen.dart';
import 'package:viora/features/user/presentation/pages/settings_screen.dart';
import 'package:viora/features/user/presentation/pages/profile_screen.dart';
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

  // Define the list of screens to be displayed in the body
  final List<Widget> _screens = [
    const StatusScreen(),
    const MissionsScreen(),
    const SettingsScreen(),
  ];

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
      drawer: VioraDrawer(
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
        // Use IndexedStack to preserve state of screens when switching
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
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
