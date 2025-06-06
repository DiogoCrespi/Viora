import 'dart:async';
import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/screens/main_screen.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'dart:math' as math;
import 'package:flame/events.dart';

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  late SpaceGame game;

  @override
  void initState() {
    super.initState();
    game = SpaceGame(onReturnToMenu: _goToStatusScreen);
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
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'pause': (context, game) => PauseMenu(game: game as SpaceGame),
        },
      ),
    );
  }
}

class SpaceGame extends FlameGame
    with HasCollisionDetection, MouseMovementDetector, TapDetector {
  final VoidCallback onReturnToMenu;
  SpaceGame({required this.onReturnToMenu});
  late Player player;
  late TextComponent scoreText;
  int score = 0;
  bool gameOver = false;
  Rect? _menuButtonRect;
  final List<ProjectileComponent> projectiles = [];
  final navigatorKey = GlobalKey<NavigatorState>();
  late final Timer _enemySpawnTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Fundo gradiente do tema
    add(BackgroundComponent());
    // Player
    player = Player();
    add(player);
    // Pontuação
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
    // Iniciar spawn de inimigos
    _enemySpawnTimer = Timer(2, onTick: _spawnEnemy, repeat: true);
    _enemySpawnTimer.start();
    add(TimerComponent(period: 2, onTick: _spawnEnemy, repeat: true));
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

    // Verificar colisões
    for (final projectile in List<ProjectileComponent>.from(projectiles)) {
      for (final component in children) {
        if (component is EnemyComponent) {
          if (projectile.hitbox.containsPoint(component.position) ||
              component.hitbox.containsPoint(projectile.position)) {
            // Colisão projétil-inimigo
            projectile.removeFromParent();
            projectiles.remove(projectile);
            component.removeFromParent();
            updateScore(100);
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
          // Colisão player-inimigo
          component.removeFromParent();
          endGame();
          break;
        }
      }
    }
  }

  void _spawnEnemy() {
    if (!gameOver) {
      final random = math.Random();
      final enemy = EnemyComponent(
        position: Vector2(
          random.nextDouble() * size.x,
          -40,
        ),
      );
      add(enemy);
    }
  }

  void updateScore(int points) {
    score += points;
    scoreText.text = 'Score: $score';
  }

  void endGame() {
    gameOver = true;
    pauseEngine();
    _enemySpawnTimer.stop();
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
      final buttonRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.6),
        width: 200,
        height: 50,
      );
      final buttonPaint = Paint()
        ..color = AppTheme.sunsetOrange
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(buttonRect, const Radius.circular(25)),
        buttonPaint,
      );
      final buttonText = TextPainter(
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
      buttonText.layout();
      buttonText.paint(
        canvas,
        Offset(
          buttonRect.center.dx - buttonText.width / 2,
          buttonRect.center.dy - buttonText.height / 2,
        ),
      );
      _menuButtonRect = buttonRect;
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
      }
    } else if (!gameOver) {
      player.shoot(this);
    }
  }
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

class Player extends PositionComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  Vector2 target = Vector2.zero();
  late RectangleHitbox hitbox;
  late Paint _paint;

  Player() : super(size: Vector2(50, 50), position: Vector2(400, 500)) {
    hitbox = RectangleHitbox(
      size: Vector2(40, 40),
      position: Vector2(5, 5),
    );
    add(hitbox);
    _paint = Paint()..color = Colors.white;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      position += (target - position) * 0.2;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2, 0)
        ..lineTo(size.x, size.y)
        ..lineTo(0, size.y)
        ..close(),
      _paint,
    );
  }

  void shoot(SpaceGame game) {
    if (!game.gameOver) {
      final projectile = ProjectileComponent(
        position: position + Vector2(size.x / 2 - 5, 0),
      );
      game.add(projectile);
      game.projectiles.add(projectile);
    }
  }
}

class ProjectileComponent extends PositionComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  late RectangleHitbox hitbox;
  late Paint _paint;

  ProjectileComponent({required Vector2 position})
      : super(size: Vector2(10, 20), position: position) {
    hitbox = RectangleHitbox(
      size: Vector2(8, 16),
      position: Vector2(1, 2),
    );
    add(hitbox);
    _paint = Paint()..color = Colors.white;
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

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}

class EnemyComponent extends PositionComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  late RectangleHitbox hitbox;
  late Paint _paint;

  EnemyComponent({required Vector2 position}) : super(size: Vector2(40, 40)) {
    this.position = position;
    hitbox = RectangleHitbox(
      size: Vector2(36, 36),
      position: Vector2(2, 2),
    );
    add(hitbox);
    _paint = Paint()..color = Colors.white;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.gameOver) {
      position.y += 100 * dt;
      if (position.y > gameRef.size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
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
