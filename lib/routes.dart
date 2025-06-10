import 'package:flutter/material.dart';
import 'package:viora/presentation/screens/splash_screen.dart';
import 'package:viora/presentation/screens/auth/login_screen.dart';
import 'package:viora/presentation/screens/auth/register_screen.dart';
import 'package:viora/presentation/screens/auth/forgot_password_screen.dart';
import 'package:viora/presentation/screens/auth/reset_password_screen.dart';
import 'package:viora/presentation/screens/auth/profile_screen.dart';
import 'package:viora/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:viora/presentation/screens/main_screen.dart';
import 'package:viora/presentation/screens/profile/status_screen.dart';
import 'package:viora/presentation/screens/profile/settings_screen.dart';
import 'package:viora/presentation/screens/game/missions_screen.dart';
import 'package:viora/presentation/screens/game/space_shooter_game.dart';

/// Classe responsável por gerenciar todas as rotas da aplicação
class AppRoutes {
  // Construtor privado para evitar instanciação
  AppRoutes._();

  // Nomes das rotas
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String status = '/status';
  static const String settings = '/settings';
  static const String missions = '/missions';
  static const String game = '/game';

  /// Configuração das rotas da aplicação
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    
    if (routeName == splash) {
      return _buildRoute(
        settings,
        const SplashScreen(),
      );
    } else if (routeName == onboarding) {
      return _buildRoute(
        settings,
        OnboardingScreen(),
      );
    } else if (routeName == login) {
      return _buildRoute(
        settings,
        LoginScreen(),
      );
    } else if (routeName == register) {
      return _buildRoute(
        settings,
        RegisterScreen(),
      );
    } else if (routeName == forgotPassword) {
      return _buildRoute(
        settings,
        ForgotPasswordScreen(),
      );
    } else if (routeName == resetPassword) {
      final args = settings.arguments as Map<String, dynamic>?;
      final email = args?['email'] as String? ?? '';
      return _buildRoute(
        settings,
        ResetPasswordScreen(email: email),
      );
    } else if (routeName == main) {
      final args = settings.arguments as Map<String, dynamic>?;
      final selectedIndex = args?['selectedIndex'] as int? ?? 0;
      return _buildRoute(
        settings,
        MainScreen(selectedIndex: selectedIndex),
      );
    } else if (routeName == profile) {
      return _buildRoute(
        settings,
        ProfileScreen(),
      );
    } else if (routeName == status) {
      return _buildRoute(
        settings,
        StatusScreen(),
      );
    } else if (routeName == settings) {
      return _buildRoute(
        settings,
        SettingsScreen(),
      );
    } else if (routeName == missions) {
      return _buildRoute(
        settings,
        MissionsScreen(),
      );
    } else if (routeName == game) {
      return _buildRoute(
        settings,
        SpaceShooterGame(),
      );
    } else {
      return _buildRoute(
        settings,
        _buildErrorRoute(settings.name),
      );
    }
  }

  /// Constrói uma rota com transição personalizada
  static Route<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }

  /// Constrói uma rota com transição de fade
  static Route<dynamic> _buildFadeRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Constrói uma rota com transição de slide
  static Route<dynamic> _buildSlideRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Página de erro para rotas não encontradas
  static Widget _buildErrorRoute(String? routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Rota não encontrada',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A rota "$routeName" não existe.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // Navegar para a tela principal
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    main,
                    (route) => false,
                  );
                },
                child: const Text('Voltar ao Início'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navegação com remoção de todas as rotas anteriores
  static Future<dynamic> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navegação com remoção de rotas até uma condição específica
  static Future<dynamic> pushNamedAndRemoveUntilCondition(
    BuildContext context,
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Navegação simples
  static Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navegação com resultado
  static Future<dynamic> pushNamedForResult(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Substitui a rota atual
  static Future<dynamic> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
    dynamic result,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Volta para a rota anterior
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Verifica se pode voltar
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Volta para a rota anterior se possível
  static Future<bool> maybePop(BuildContext context, [dynamic result]) {
    return Navigator.maybePop(context, result);
  }
}

/// Extensão para facilitar o uso das rotas
extension AppRoutesExtension on BuildContext {
  /// Navega para uma rota específica
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return AppRoutes.pushNamed(this, routeName, arguments: arguments);
  }

  /// Navega para uma rota removendo todas as anteriores
  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    return AppRoutes.pushNamedAndRemoveUntil(this, routeName, arguments: arguments);
  }

  /// Substitui a rota atual
  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments, dynamic result}) {
    return AppRoutes.pushReplacementNamed(this, routeName, arguments: arguments, result: result);
  }

  /// Volta para a rota anterior
  void pop([dynamic result]) {
    AppRoutes.pop(this, result);
  }

  /// Verifica se pode voltar
  bool get canPop => AppRoutes.canPop(this);

  /// Volta para a rota anterior se possível
  Future<bool> maybePop([dynamic result]) => AppRoutes.maybePop(this, result);
} 