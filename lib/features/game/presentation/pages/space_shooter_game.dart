import 'dart:async';
import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/pages/main_screen.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:viora/features/game/data/repositories/game_repository.dart';
import 'package:viora/l10n/app_localizations.dart';

class JoystickDetails {
  final Vector2 direction;
  JoystickDetails(this.direction);
}

class SpaceShooterGame extends StatefulWidget {
  final String userId;
  const SpaceShooterGame({super.key, required this.userId});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  late SpaceGame game;
  static bool isMouseControl = true;

  @override
  void initState() {
    super.initState();
    game = SpaceGame(
      onReturnToMenu: _goToStatusScreen,
      isMouseControl: isMouseControl,
      userId: widget.userId,
    );
  }

  void _toggleControl() {
    setState(() {
      isMouseControl = !isMouseControl;
      game.toggleControl(isMouseControl);
    });
  }

  void _goToStatusScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(selectedIndex: 0),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'pause': (context, game) => PauseMenu(game: game as SpaceGame),
              'controls': (context, game) => ControlOverlay(
                    game: game as SpaceGame,
                    isMouseControl: isMouseControl,
                    onToggleControl: _toggleControl,
                  ),
              'mission_completed': (context, game) => MissionCompletedOverlay(
                    game: game as SpaceGame,
                  ),
            },
          ),
        ],
      ),
    );
  }
}

class ControlOverlay extends StatelessWidget {
  final SpaceGame game;
  final bool isMouseControl;
  final VoidCallback onToggleControl;

  const ControlOverlay({
    super.key,
    required this.game,
    required this.isMouseControl,
    required this.onToggleControl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botão de alternância de controles
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
        // Joystick e botão de tiro (apenas quando não estiver usando mouse)
        if (!isMouseControl) ...[
          // Joystick
          Positioned(
            left: 50,
            bottom: 50,
            child: JoystickArea(
              onDirectionChanged: (direction) {
                game.updateJoystick(JoystickDetails(direction));
              },
            ),
          ),
          // Botão de tiro
          Positioned(
            right: 50,
            bottom: 50,
            child: GestureDetector(
              onTapDown: (_) => game.player.shoot(game),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.sunsetOrange.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.sunsetOrange,
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

class JoystickArea extends StatefulWidget {
  final Function(Vector2) onDirectionChanged;

  const JoystickArea({
    super.key,
    required this.onDirectionChanged,
  });

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
            color: AppTheme.sunsetOrange,
            width: 2,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragPosition != null
                ? Offset(
                    (_dragPosition!.dx - _joystickSize / 2).clamp(
                      -(_joystickSize - _knobSize) / 2,
                      (_joystickSize - _knobSize) / 2,
                    ),
                    (_dragPosition!.dy - _joystickSize / 2).clamp(
                      -(_joystickSize - _knobSize) / 2,
                      (_joystickSize - _knobSize) / 2,
                    ),
                  )
                : Offset.zero,
            child: Container(
              width: _knobSize,
              height: _knobSize,
              decoration: BoxDecoration(
                color: AppTheme.sunsetOrange.withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.sunsetOrange,
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

class SpaceGame extends FlameGame
    with HasCollisionDetection, MouseMovementDetector, TapDetector {
  final VoidCallback onReturnToMenu;
  final String userId;
  final GameRepository _gameRepository = GameRepository();
  bool isMouseControl;
  Vector2? joystickDirection;
  late Player player;
  late TextComponent scoreText;
  int score = 0;
  bool gameOver = false;
  Rect? _menuButtonRect;
  final List<ProjectileComponent> projectiles = [];
  final navigatorKey = GlobalKey<NavigatorState>();
  late final Timer _enemySpawnTimer;
  List<Map<String, dynamic>> completedMissions = [];

  // Variáveis de progressão
  double _gameSpeed = 1.0;
  int _currentLevel = 1;
  final Map<int, int> _levelThresholds = {
    1: 0, // Nível 1: Início
    2: 500, // Nível 2: Nebulosa
    3: 1000, // Nível 3: Galáxia
    4: 2000, // Nível 4: Super Nova
    5: 4000, // Nível 5: Buraco Negro
  };

  // Constantes para cálculo exponencial
  static const double _baseSpeed = 1.0;
  static const double _speedMultiplier = 0.2;
  static const double _exponentialFactor = 1.5;

  SpaceGame({
    required this.onReturnToMenu,
    required this.userId,
    this.isMouseControl = true,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add('controls');
    add(BackgroundComponent());
    player = Player();
    add(player);
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Orbitron',
        ),
      ),
      priority: 10,
    );
    add(scoreText);
    _enemySpawnTimer = Timer(2, onTick: _spawnEnemy, repeat: true);
    _enemySpawnTimer.start();
    add(TimerComponent(period: 2, onTick: _spawnEnemy, repeat: true));
  }

  void _spawnEnemy() {
    if (!gameOver) {
      final random = math.Random();
      final enemyType = _getRandomEnemyType();
      final enemy = EnemyComponent(
        position: Vector2(
          random.nextDouble() * size.x,
          -40,
        ),
        type: enemyType,
      );
      add(enemy);
    }
  }

  EnemyType _getRandomEnemyType() {
    final random = math.Random();
    final chance = random.nextDouble();

    if (_currentLevel >= 3) {
      if (chance < 0.1) return EnemyType.diamond; // 10% chance
      if (chance < 0.3) return EnemyType.triangle; // 20% chance
      if (chance < 0.6) return EnemyType.circle; // 30% chance
      return EnemyType.square; // 40% chance
    } else if (_currentLevel >= 2) {
      if (chance < 0.2) return EnemyType.triangle; // 20% chance
      if (chance < 0.5) return EnemyType.circle; // 30% chance
      return EnemyType.square; // 50% chance
    }

    return EnemyType.square; // Nível 1: apenas quadrados
  }

  void updateScore(int points) {
    score += points;
    scoreText.text = 'Score: $score';

    // Atualiza o nível e velocidade do jogo
    _updateGameProgress();
  }

  void _updateGameProgress() {
    // Atualiza o nível baseado na pontuação
    final sortedLevels = _levelThresholds.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    for (var entry in sortedLevels) {
      if (score >= entry.value) {
        if (_currentLevel != entry.key) {
          _currentLevel = entry.key;
          // Cálculo exponencial da velocidade
          _gameSpeed = _baseSpeed +
              (_speedMultiplier *
                  math.pow(_exponentialFactor, _currentLevel - 1));

          // Atualiza o timer de spawn com a nova velocidade
          _enemySpawnTimer.stop();
          add(TimerComponent(
            period: 2 / _gameSpeed,
            onTick: _spawnEnemy,
            repeat: true,
          ));
        }
        break;
      }
    }
  }

  void resetGame() {
    score = 0;
    gameOver = false;
    _currentLevel = 1;
    _gameSpeed = _baseSpeed;
    scoreText.text = 'Score: 0';
    projectiles.clear();
    children
        .whereType<EnemyComponent>()
        .forEach((enemy) => enemy.removeFromParent());
    children
        .whereType<ProjectileComponent>()
        .forEach((projectile) => projectile.removeFromParent());

    player.position = Vector2(
      size.x / 2 - player.size.x / 2,
      size.y * 0.8 - player.size.y / 2,
    );

    _enemySpawnTimer.stop();
    add(TimerComponent(period: 2, onTick: _spawnEnemy, repeat: true));
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) {
      _menuButtonRect ??= Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.6),
        width: 200,
        height: 50,
      );
      return;
    }

    if (!isMouseControl && joystickDirection != null) {
      player.position += joystickDirection! * 500 * dt;
      player.position.x = player.position.x.clamp(
        player.size.x / 2,
        size.x - player.size.x / 2,
      );
      player.position.y = player.position.y.clamp(
        player.size.y / 2,
        size.y - player.size.y / 2,
      );
    }

    // Verificar colisões
    for (final projectile in List<ProjectileComponent>.from(projectiles)) {
      for (final component in children) {
        if (component is EnemyComponent) {
          if (projectile.hitbox.containsPoint(component.position) ||
              component.hitbox.containsPoint(projectile.position)) {
            projectile.removeFromParent();
            projectiles.remove(projectile);
            component.removeFromParent();
            updateScore(component.points);
            break;
          }
        }
      }
    }

    // Verificar colisão player-inimigo
    for (final component in children) {
      if (component is EnemyComponent) {
        if (player.hitbox.containsPoint(component.position) ||
            component.hitbox.containsPoint(player.position)) {
          component.removeFromParent();
          endGame();
          break;
        }
      }
    }
  }

  void endGame() {
    gameOver = true;
    pauseEngine();
    _enemySpawnTimer.stop();

    // Salvar pontuação no banco
    _gameRepository.saveGameScore(
      userId: userId,
      score: score,
      level: _currentLevel,
    );

    // Verificar missões completadas
    _checkCompletedMissions();
  }

  Future<void> _checkCompletedMissions() async {
    try {
      await _gameRepository.checkAndUpdateMissions(
        userId: userId,
        score: score,
        level: _currentLevel,
      );
      // Se quiser mostrar o overlay, busque as missões completadas separadamente, por exemplo:
      // final completed = await _gameRepository.getUserMissions(userId);
      // overlays.add('mission_completed');
    } catch (e) {
      print('Erro ao verificar missões: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameOver) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.black.withOpacity(0.7),
      );
      final gameOverText = TextPainter(
        text: const TextSpan(
          text: 'GAME OVER',
          style: TextStyle(
            color: AppTheme.sunsetOrange,
            fontSize: 48,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      gameOverText.layout();
      gameOverText.paint(
        canvas,
        Offset((size.x - gameOverText.width) / 2, size.y * 0.3),
      );
      final scoreText = TextPainter(
        text: TextSpan(
          text: 'Pontuação: $score',
          style: const TextStyle(
            color: AppTheme.agedBeige,
            fontSize: 24,
            fontFamily: 'Exo2',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      scoreText.layout();
      scoreText.paint(
        canvas,
        Offset((size.x - scoreText.width) / 2, size.y * 0.45),
      );

      // Botão de reiniciar
      final restartButtonRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.55),
        width: 200,
        height: 50,
      );
      final buttonPaint = Paint()
        ..color = AppTheme.sunsetOrange
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(restartButtonRect, const Radius.circular(25)),
        buttonPaint,
      );
      final restartButtonText = TextPainter(
        text: const TextSpan(
          text: 'Reiniciar',
          style: TextStyle(
            color: AppTheme.geometricBlack,
            fontSize: 18,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      restartButtonText.layout();
      restartButtonText.paint(
        canvas,
        Offset(
          restartButtonRect.center.dx - restartButtonText.width / 2,
          restartButtonRect.center.dy - restartButtonText.height / 2,
        ),
      );

      // Botão de voltar ao menu
      final menuButtonRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.65),
        width: 200,
        height: 50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(menuButtonRect, const Radius.circular(25)),
        buttonPaint,
      );
      final menuButtonText = TextPainter(
        text: const TextSpan(
          text: 'Voltar ao Menu',
          style: TextStyle(
            color: AppTheme.geometricBlack,
            fontSize: 18,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      menuButtonText.layout();
      menuButtonText.paint(
        canvas,
        Offset(
          menuButtonRect.center.dx - menuButtonText.width / 2,
          menuButtonRect.center.dy - menuButtonText.height / 2,
        ),
      );
      _menuButtonRect = menuButtonRect;
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (!gameOver) {
      player.target = info.eventPosition.global;
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameOver && _menuButtonRect != null) {
      final touchPoint =
          Offset(info.eventPosition.global.x, info.eventPosition.global.y);
      if (_menuButtonRect!.contains(touchPoint)) {
        onReturnToMenu();
      } else {
        // Verificar se clicou no botão de reiniciar
        final restartButtonRect = Rect.fromCenter(
          center: Offset(size.x / 2, size.y * 0.55),
          width: 200,
          height: 50,
        );
        if (restartButtonRect.contains(touchPoint)) {
          resetGame();
        }
      }
    } else if (!gameOver) {
      player.shoot(this);
    }
  }

  void toggleControl(bool useMouse) {
    isMouseControl = useMouse;
    if (useMouse) {
      joystickDirection = null;
    }
  }

  void updateJoystick(JoystickDetails details) {
    if (!isMouseControl) {
      joystickDirection = details.direction;
    }
  }
}

enum EnemyType {
  square, // Básico: 50 pontos
  circle, // Médio: 75 pontos
  triangle, // Difícil: 100 pontos
  diamond, // Raro: 150 pontos
}

class BackgroundComponent extends Component with HasGameRef<SpaceGame> {
  late Paint _paint;
  late List<LinearGradient> _gradients;
  int _currentGradientIndex = 0;
  late Rect _gameRect;

  BackgroundComponent() {
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

    // Inicializa o retângulo do jogo
    _gameRect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    _updateGradient();
  }

  void _updateGradient() {
    if (!isMounted) return;

    final score = gameRef.score;
    int newIndex = 0;

    if (score >= 1000) {
      newIndex = 2; // Galáxia
    } else if (score >= 500) {
      newIndex = 1; // Nebulosa
    }

    if (newIndex != _currentGradientIndex || _paint.shader == null) {
      _currentGradientIndex = newIndex;
      // Atualiza o retângulo do jogo
      _gameRect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
      // Cria um novo shader com o retângulo atualizado
      _paint.shader = _gradients[_currentGradientIndex].createShader(_gameRect);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Atualiza o retângulo quando o tamanho do jogo muda
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
    if (!isMounted) return;

    // Desenha o gradiente usando o retângulo atualizado
    canvas.drawRect(_gameRect, _paint);
  }
}

class Player extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  Vector2 target = Vector2.zero();
  late RectangleHitbox hitbox;

  Player() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('player.png');
    anchor = Anchor.center;
    position = Vector2(
      gameRef.size.x / 2,
      gameRef.size.y * 0.8,
    );
    hitbox = RectangleHitbox(
      size: Vector2(40, 40),
      position: Vector2(5, 5),
    );
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      if (gameRef.isMouseControl) {
        position += (target - position) * 0.2;
      }
    }
  }

  void shoot(SpaceGame game) {
    if (!game.gameOver) {
      final projectile = ProjectileComponent(
        position: position + Vector2(0, -size.y / 2),
      );
      game.add(projectile);
      game.projectiles.add(projectile);
    }
  }
}

class ProjectileComponent extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  late RectangleHitbox hitbox;

  ProjectileComponent({required Vector2 position})
      : super(size: Vector2(10, 20), position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('bullet.png');
    anchor = Anchor.center;
    hitbox = RectangleHitbox(
      size: Vector2(8, 16),
      position: Vector2(1, 2),
    );
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      position.y -= 400 * dt;
      if (position.y < -size.y) {
        removeFromParent();
        gameRef.projectiles.remove(this);
      }
    }
  }
}

class BulletEnemyComponent extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  late RectangleHitbox hitbox;

  BulletEnemyComponent({required Vector2 position})
      : super(size: Vector2(14, 28), position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('bullet_enemy.png');
    anchor = Anchor.center;
    hitbox = RectangleHitbox(
      size: Vector2(12, 24),
      position: Vector2(1, 2),
    );
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      position.y += 300 * dt;
      if (position.y > gameRef.size.y + size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player && !gameRef.gameOver) {
      removeFromParent();
      gameRef.endGame();
    }
  }
}

class EnemyComponent extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  late RectangleHitbox hitbox;
  final EnemyType type;
  final int points;

  // Controle de perseguição
  bool _isChasing = false;
  double _chaseTime = 0;
  static const double _chaseDuration = 5.0; // segundos

  // Controle de tiro para EnemyType.circle
  double _shootTimer = 0;
  static const double _shootInterval = 0.7; // segundos

  EnemyComponent({
    required Vector2 position,
    this.type = EnemyType.square,
  })  : points = _getPointsForType(type),
        super(size: Vector2(40, 40), position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    String spritePath;
    switch (type) {
      case EnemyType.square:
        spritePath = 'enemy.png';
        break;
      case EnemyType.circle:
        spritePath = 'enemy1.png';
        _shootTimer = 0;
        break;
      case EnemyType.triangle:
        spritePath = 'enemy2.png';
        _isChasing = true;
        _chaseTime = 0;
        break;
      case EnemyType.diamond:
        spritePath = 'enemy2.png';
        break;
    }
    sprite = await gameRef.loadSprite(spritePath);
    anchor = Anchor.center;
    hitbox = RectangleHitbox(
      size: Vector2(36, 36),
      position: Vector2(2, 2),
    );
    add(hitbox);
  }

  static int _getPointsForType(EnemyType type) {
    switch (type) {
      case EnemyType.square:
        return 50;
      case EnemyType.circle:
        return 75;
      case EnemyType.triangle:
        return 100;
      case EnemyType.diamond:
        return 150;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      if (type == EnemyType.triangle && _isChasing) {
        _chaseTime += dt;
        // Persegue o player
        final playerPos = gameRef.player.position;
        final direction = (playerPos - position).normalized();
        position += direction * 120 * dt * gameRef._gameSpeed;
        if (_chaseTime >= _chaseDuration) {
          _isChasing = false;
        }
      } else {
        // Movimento normal para baixo
        position.y += 100 * dt * gameRef._gameSpeed;
      }
      if (type == EnemyType.circle) {
        _shootTimer += dt;
        if (_shootTimer >= _shootInterval) {
          _shootTimer = 0;
          // Probabilidade exponencial baseada na pontuação
          final score = gameRef.score;
          // Exemplo: prob = min(0.05 * exp(score/500), 0.8)
          final prob = (0.05 * math.exp(score / 500)).clamp(0, 0.8);
          if (math.Random().nextDouble() < prob) {
            // Atira
            final bullet = BulletEnemyComponent(
                position: position + Vector2(0, size.y / 2));
            gameRef.add(bullet);
          }
        }
      }
      if (position.y > gameRef.size.y) {
        removeFromParent();
      }
    }
  }
}

class PauseMenu extends StatelessWidget {
  final SpaceGame game;
  const PauseMenu({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(
              'PAUSADO',
              style: theme.futuristicTitle,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resumeEngine();
                game.overlays.remove('pause');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.sunsetOrange,
                foregroundColor: AppTheme.geometricBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Continuar',
                style: theme.futuristicSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MissionCompletedOverlay extends StatelessWidget {
  final SpaceGame game;

  const MissionCompletedOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.sunsetOrange,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Missão Concluída!',
              style: theme.futuristicTitle,
            ),
            const SizedBox(height: 16),
            ...game.completedMissions.map((mission) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        mission['title'],
                        style: theme.futuristicSubtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission['description'],
                        style: const TextStyle(
                          color: AppTheme.agedBeige,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recompensa: ${mission['xp_reward']} XP',
                        style: TextStyle(
                          color: AppTheme.sunsetOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('mission_completed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sunsetOrange,
                foregroundColor: AppTheme.geometricBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Continuar',
                style: theme.futuristicSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
