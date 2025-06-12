import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:viora/features/game/presentation/games/space_shooter_game.dart';
import 'package:viora/features/user/presentation/pages/status_screen.dart';
import 'package:viora/features/game/presentation/screens/missions_screen.dart';

class GameTestScreen extends StatefulWidget {
  const GameTestScreen({Key? key}) : super(key: key);

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen> {
  late SpaceShooterGame _game;
  bool _isMouseControl = true;
  final String _userId = 'test_user_1';

  @override
  void initState() {
    super.initState();
    _game = SpaceShooterGame(userId: _userId);
  }

  void _toggleControl() {
    setState(() {
      _isMouseControl = !_isMouseControl;
      _game.toggleControl(_isMouseControl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<SpaceShooterGame>(
            game: _game,
            overlayBuilderMap: {
              'pause': (context, game) =>
                  PauseMenu(game: game as SpaceShooterGame),
              'gameOver': (context, game) => GameOverOverlay(
                    game: game as SpaceShooterGame,
                    score: (game as SpaceShooterGame).score,
                    time: (game as SpaceShooterGame).gameTime,
                    onRestart: (game as SpaceShooterGame).resetGame,
                  ),
              'controls': (context, game) => ControlOverlay(
                    game: game as SpaceShooterGame,
                    isMouseControl: _isMouseControl,
                    onToggleControl: _toggleControl,
                  ),
            },
            initialActiveOverlays: const ['controls'],
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _game.pauseEngine();
                    _game.overlays.add('pause');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pausar',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatusScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionsScreen(userId: _userId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Missões',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
