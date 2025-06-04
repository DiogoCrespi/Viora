import 'package:flutter/material.dart';
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

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(prefs),
        ),
        ChangeNotifierProvider(
          // Added
          create: (_) => LocaleProvider(prefs),
        ),
      ],
      child: const VioraApp(hasSeenOnboarding: false),
    ),
  );

  FlutterNativeSplash.remove();
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
    final localeProvider = Provider.of<LocaleProvider>(context); // Added

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          // title: 'Viora', // Replaced by onGenerateTitle
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)!.appTitle, // Added
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: localeProvider.locale, // Added
          localizationsDelegates:
              AppLocalizations.localizationsDelegates, // Modified
          supportedLocales: AppLocalizations.supportedLocales, // Modified
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: fontSizeProvider.fontSize,
              ),
              child: child!,
            );
          },
          initialRoute: hasSeenOnboarding ? '/main' : '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/main': (context) => const MainScreen(selectedIndex: 0),
            '/game': (context) => const SpaceShooterGame(),
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
