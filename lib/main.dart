import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/presentation/providers/theme_provider.dart';
import 'package:viora/presentation/providers/font_size_provider.dart';
import 'package:viora/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:viora/presentation/pages/main_screen.dart';
import 'package:viora/features/game/presentation/pages/space_shooter_game.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:viora/presentation/providers/locale_provider.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/features/user/presentation/providers/user_provider.dart';
import 'package:viora/features/user/domain/repositories/user_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/features/auth/presentation/pages/login_screen.dart';
import 'package:viora/routes.dart';

// Conditional imports for platform-specific code
import 'core/platform/platform_stub.dart'
    if (dart.library.io) 'core/platform/platform_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SQLite for desktop platforms
  if (!kIsWeb) {
    try {
      if (Platform.isDesktop) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (e) {
      debugPrint('Error initializing SQLite: $e');
    }
  }

  // Initialize Supabase (apenas verificar conexão, não inicializar novamente)
  try {
    // Inicializa o Supabase primeiro
    final initialized = await SupabaseConfig.initialize();
    if (!initialized) {
      debugPrint(
          'Erro: Não foi possível inicializar o Supabase. Último erro: ${SupabaseConfig.lastError}');
      // TODO: Mostrar uma tela de erro ou tentar reconectar
    } else {
      final session = SupabaseConfig.client.auth.currentSession;
      debugPrint('Main: Current session after init: ${session?.user.id}');
    }
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    // TODO: Mostrar uma tela de erro ou tentar reconectar
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  debugPrint('Main: Has seen onboarding: $hasSeenOnboarding');

  // Initialize database and repositories
  Database? db;
  if (!kIsWeb) {
    try {
      if (Platform.isDesktop) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        db = await databaseFactoryFfi.openDatabase('viora.db');
      }
    } catch (e) {
      debugPrint('Error initializing SQLite: $e');
    }
  }
  final userProvider = UserProvider(db);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(prefs),
        ),
      ],
      child: VioraApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class VioraApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const VioraApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Viora',
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontSizeProvider.fontSize),
              ),
              child: child!,
            );
          },
          initialRoute: AppRoutes.splash,
          onGenerateRoute: (settings) {
            final session = SupabaseConfig.client.auth.currentSession;
            debugPrint(
                'VioraApp: Generating route ${settings.name} with session: ${session?.user.id}');

            // Lógica de autenticação para rotas protegidas
            if (_isProtectedRoute(settings.name) && session == null) {
              debugPrint(
                  'VioraApp: Redirecting to login (protected route without session)');
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            }

            // Usa o sistema de rotas centralizado
            return AppRoutes.generateRoute(settings);
          },
        );
      },
    );
  }

  /// Verifica se uma rota requer autenticação
  bool _isProtectedRoute(String? routeName) {
    if (routeName == null) return false;

    final protectedRoutes = [
      AppRoutes.main,
      AppRoutes.profile,
      AppRoutes.status,
      AppRoutes.settings,
      AppRoutes.missions,
      AppRoutes.game,
    ];

    return protectedRoutes.contains(routeName);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viora')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Viora',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'A futuristic experience',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: () {}, child: const Text('Get Started')),
          ],
        ),
      ),
    );
  }
}
