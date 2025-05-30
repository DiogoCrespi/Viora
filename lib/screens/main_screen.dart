import 'package:flutter/material.dart';
import 'package:viora/theme/app_theme.dart';
import 'package:viora/widgets/futuristic_drawer.dart';
import 'package:viora/screens/status_screen.dart';
import 'package:viora/screens/missions_screen.dart';
import 'package:viora/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  int _selectedIndex = 0;

  final List<String> _sections = ['Status', 'Missões', 'Configurações'];

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _sections[_selectedIndex],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
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
              // TODO: Implementar perfil
            },
          ),
        ],
      ),
      drawer: FuturisticDrawer(
        selectedIndex: _selectedIndex,
        sections: _sections,
        onSectionSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body:
          _selectedIndex == 0
              ? const StatusScreen()
              : _selectedIndex == 1
              ? const MissionsScreen()
              : _selectedIndex == 2
              ? const SettingsScreen()
              : Center(
                child: Text(
                  'Conteúdo da seção ${_sections[_selectedIndex]}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar ação principal
        },
        backgroundColor: AppTheme.metallicGold,
        child: const Icon(Icons.add, color: AppTheme.deepBrown),
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
