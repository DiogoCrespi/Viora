import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:viora/features/game/data/repositories/game_repository.dart';

class SpaceShooterGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  final String userId;
  final GameRepository _gameRepository = GameRepository();
  late TextComponent _scoreText;
  late TextComponent _timerText;
  int _score = 0;
  int _gameTime = 0;
  Timer? _gameTimer;
  bool _isGameOver = false;

  // Getters públicos
  int get score => _score;
  int get gameTime => _gameTime;

  // Controle moderno
  bool isMouseControl = true;
  Vector2 joystickDirection = Vector2.zero();
  Player? _playerRef;

  SpaceShooterGame({required this.userId});

  // Alternar controle
  void toggleControl(bool useMouse) {
    isMouseControl = useMouse;
    if (useMouse) {
      joystickDirection = Vector2.zero();
    }
  }

  // Atualizar direção do joystick
  void updateJoystick(Vector2 direction) {
    joystickDirection = direction;
  }

  // Atirar pelo overlay
  void playerShoot() {
    _playerRef?.shoot();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fundo gradiente
    add(BackgroundGradientComponent());

    // HUD estilizado
    _scoreText = TextComponent(
      text: 'Pontuação: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 28,
          fontFamily: 'Orbitron',
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2)),
          ],
        ),
      ),
      priority: 10,
    );
    add(_scoreText);

    _timerText = TextComponent(
      text: 'Tempo: 0s',
      position: Vector2(20, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontFamily: 'Orbitron',
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(blurRadius: 6, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      ),
      priority: 10,
    );
    add(_timerText);

    // Iniciar timer do jogo
    _gameTimer = Timer(1, onTick: () {
      _gameTime++;
      _timerText.text = 'Tempo: ${_gameTime}s';
    }, repeat: true);
    _gameTimer?.start();

    // Adicionar jogador
    final player = Player();
    player.position = Vector2(size.x / 2, size.y - 100);
    add(player);
    _playerRef = player;

    // Adicionar spawner de inimigos
    add(EnemySpawner());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _gameTimer?.update(dt);

    // Movimento do player com joystick
    if (!isMouseControl && _playerRef != null) {
      _playerRef!.position += joystickDirection * 300 * dt;
      _playerRef!.position.x = _playerRef!.position.x
          .clamp(_playerRef!.size.x / 2, size.x - _playerRef!.size.x / 2);
      _playerRef!.position.y = _playerRef!.position.y
          .clamp(_playerRef!.size.y / 2, size.y - _playerRef!.size.y / 2);
    }
  }

  void addScore(int points) {
    _score += points;
    _scoreText.text = 'Pontuação: $_score';
  }

  void gameOver() {
    if (!_isGameOver) {
      _isGameOver = true;
      _gameTimer?.stop();

      // Salvar pontuação
      _gameRepository.saveGameScore(
        userId: userId,
        score: _score,
        duration: _gameTime,
      );

      // Mostrar overlay de game over estilizado
      overlays.add('gameOver');
    }
  }

  void resetGame() {
    _score = 0;
    _gameTime = 0;
    _isGameOver = false;
    _scoreText.text = 'Pontuação: 0';
    _timerText.text = 'Tempo: 0s';
    _gameTimer?.start();

    // Remover componentes antigos
    children.whereType<Enemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());

    // Adicionar novo jogador
    final player = Player();
    player.position = Vector2(size.x / 2, size.y - 100);
    add(player);
    _playerRef = player;

    // Remover overlay de game over
    overlays.remove('gameOver');
  }
}

class Player extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  static const double _speed = 300.0;

  Player() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('player.png');
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Movimento do jogador será controlado pelo TapDetector
  }

  void moveTo(Vector2 position) {
    this.position = position;
  }

  void shoot() {
    final bullet = Bullet();
    bullet.position = position.clone();
    gameRef.add(bullet);
  }
}

class Bullet extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  static const double _speed = 500.0;

  Bullet() : super(size: Vector2(10, 20));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('bullet.png');
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= _speed * dt;

    if (position.y < -size.y) {
      removeFromParent();
    }
  }
}

class Enemy extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  static const double _speed = 200.0;
  final Random _random = Random();

  Enemy() : super(size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('enemy.png');
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;

    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }
}

class EnemySpawner extends Component with HasGameRef<SpaceShooterGame> {
  final Random _random = Random();
  Timer? _spawnTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnTimer = Timer(1, onTick: _spawnEnemy, repeat: true);
    _spawnTimer?.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer?.update(dt);
  }

  void _spawnEnemy() {
    final enemy = Enemy();
    enemy.position = Vector2(
      _random.nextDouble() * (gameRef.size.x - enemy.size.x),
      -enemy.size.y,
    );
    gameRef.add(enemy);
  }
}

// Overlay de game over estilizado
class GameOverOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  final int score;
  final int time;
  final VoidCallback onRestart;

  const GameOverOverlay({
    Key? key,
    required this.game,
    required this.score,
    required this.time,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pontuação: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tempo: ${time}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRestart,
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
                    'Reiniciar',
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
                    game.overlays.remove('gameOver');
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Componente de fundo gradiente dinâmico
class BackgroundGradientComponent extends Component
    with HasGameRef<SpaceShooterGame> {
  late Paint _paint;
  late List<LinearGradient> _gradients;
  int _currentGradientIndex = 0;
  late Rect _gameRect;

  BackgroundGradientComponent() {
    _paint = Paint();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _gradients = [
      // Fase 1: Espaço inicial
      const LinearGradient(
        colors: [Colors.black, Color.fromARGB(255, 220, 78, 22)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1.0],
      ),
      // Fase 2: Nebulosa
      const LinearGradient(
        colors: [Color(0xFF2C1810), Color(0xFFD4AF37)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1.0],
      ),
      // Fase 3: Galáxia
      const LinearGradient(
        colors: [Color(0xFFD4AF37), Color(0xFFF5E6D3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1.0],
      ),
    ];
    _gameRect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    _updateGradient();
  }

  void _updateGradient() {
    final score = gameRef._score;
    int newIndex = 0;
    if (score >= 10000) {
      newIndex = 2; // Galáxia
    } else if (score >= 5000) {
      newIndex = 1; // Nebulosa
    }
    if (newIndex != _currentGradientIndex || _paint.shader == null) {
      _currentGradientIndex = newIndex;
      _gameRect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
      _paint.shader = _gradients[_currentGradientIndex].createShader(_gameRect);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _gameRect = Rect.fromLTWH(0, 0, size.x, size.y);
    _updateGradient();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateGradient();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_gameRect, _paint);
  }
}

// Overlay de pause
class PauseMenu extends StatelessWidget {
  final SpaceShooterGame game;
  const PauseMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSADO',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resumeEngine();
                game.overlays.remove('pause');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Continuar',
                  style: TextStyle(fontFamily: 'Orbitron')),
            ),
          ],
        ),
      ),
    );
  }
}

// Overlay de controles
class ControlOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  final bool isMouseControl;
  final VoidCallback onToggleControl;

  const ControlOverlay({
    Key? key,
    required this.game,
    required this.isMouseControl,
    required this.onToggleControl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(
              isMouseControl ? Icons.touch_app : Icons.mouse,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onToggleControl,
          ),
        ),
        if (!isMouseControl) ...[
          Positioned(
            left: 50,
            bottom: 50,
            child: JoystickArea(
              onDirectionChanged: (direction) {
                game.updateJoystick(direction);
              },
            ),
          ),
          Positioned(
            right: 50,
            bottom: 50,
            child: GestureDetector(
              onTapDown: (_) => game.playerShoot(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFD4AF37).withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.radio_button_checked,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Joystick virtual
class JoystickArea extends StatefulWidget {
  final Function(Vector2) onDirectionChanged;
  const JoystickArea({Key? key, required this.onDirectionChanged})
      : super(key: key);
  @override
  State<JoystickArea> createState() => _JoystickAreaState();
}

class _JoystickAreaState extends State<JoystickArea> {
  Offset? _dragPosition;
  final double _joystickSize = 120.0;
  final double _knobSize = 40.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _dragPosition = details.localPosition;
        });
        _updateDirection();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragPosition = details.localPosition;
        });
        _updateDirection();
      },
      onPanEnd: (_) {
        setState(() {
          _dragPosition = null;
        });
        widget.onDirectionChanged(Vector2.zero());
      },
      child: Container(
        width: _joystickSize,
        height: _joystickSize,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFFD4AF37),
            width: 2,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragPosition != null
                ? Offset(
                    (_dragPosition!.dx - _joystickSize / 2).clamp(
                        -(_joystickSize - _knobSize) / 2,
                        (_joystickSize - _knobSize) / 2),
                    (_dragPosition!.dy - _joystickSize / 2).clamp(
                        -(_joystickSize - _knobSize) / 2,
                        (_joystickSize - _knobSize) / 2),
                  )
                : Offset.zero,
            child: Container(
              width: _knobSize,
              height: _knobSize,
              decoration: BoxDecoration(
                color: Color(0xFFD4AF37).withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFD4AF37),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateDirection() {
    if (_dragPosition == null) return;
    final center = Offset(_joystickSize / 2, _joystickSize / 2);
    final delta = _dragPosition! - center;
    final distance = delta.distance;
    final maxDistance = (_joystickSize - _knobSize) / 2;
    final normalizedDelta =
        distance > maxDistance ? delta * (maxDistance / distance) : delta;
    final direction = Vector2(
      normalizedDelta.dx / maxDistance,
      normalizedDelta.dy / maxDistance,
    );
    widget.onDirectionChanged(direction);
  }
}
