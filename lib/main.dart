import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/providers/theme_provider.dart';
import 'package:viora/core/providers/font_size_provider.dart';
import 'package:viora/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:viora/presentation/screens/main_screen.dart';
import 'package:viora/presentation/screens/game/space_shooter_game.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:viora/core/providers/locale_provider.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'core/providers/user_provider.dart';
import 'core/repositories/user_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/presentation/screens/auth/login_screen.dart';

// Conditional imports for platform-specific code
import 'platform_stub.dart' if (dart.library.io) 'platform_io.dart';

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

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    final session = SupabaseConfig.client.auth.currentSession;
    debugPrint('Main: Current session after init: ${session?.user.id}');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  debugPrint('Main: Has seen onboarding: $hasSeenOnboarding');

  // Initialize database and repositories
  final userRepository = await UserRepository.create();
  final userProvider = UserProvider(userRepository);

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
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final session = SupabaseConfig.client.auth.currentSession;
            debugPrint(
                'VioraApp: Generating route ${settings.name} with session: ${session?.user.id}');

            // Se não estiver autenticado e não estiver na tela de login ou onboarding
            if (session == null &&
                settings.name != '/login' &&
                settings.name != '/') {
              debugPrint('VioraApp: Redirecting to login');
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            }

            switch (settings.name) {
              case '/':
                if (!hasSeenOnboarding) {
                  debugPrint('VioraApp: Showing onboarding');
                  return MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  );
                } else if (session == null) {
                  debugPrint('VioraApp: Redirecting to login (no session)');
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );
                } else {
                  debugPrint('VioraApp: Redirecting to main');
                  return MaterialPageRoute(
                    builder: (context) => const MainScreen(selectedIndex: 0),
                  );
                }
              case '/main':
                if (session == null) {
                  debugPrint(
                      'VioraApp: Redirecting to login (no session for main)');
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const MainScreen(selectedIndex: 0),
                );
              case '/game':
                if (session == null) {
                  debugPrint(
                      'VioraApp: Redirecting to login (no session for game)');
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const SpaceShooterGame(),
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              default:
                debugPrint('VioraApp: Redirecting to login (default)');
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
            }
          },
        );
      },
    );
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
