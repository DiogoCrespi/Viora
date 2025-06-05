import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/widgets/futuristic_drawer.dart';
import 'package:viora/presentation/screens/profile/status_screen.dart';
import 'package:viora/presentation/screens/game/missions_screen.dart';
import 'package:viora/presentation/screens/profile/settings_screen.dart';
import 'package:viora/presentation/screens/profile/profile_screen.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/providers/theme_provider.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<String> sections = [
      localizations.mainScreenStatusTab,
      localizations.mainScreenMissionsTab,
      localizations.mainScreenSettingsTab,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          sections[_selectedIndex],
          style: theme.futuristicTitle.copyWith(color: theme.textTheme.bodyLarge?.color),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
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
