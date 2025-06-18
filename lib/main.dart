import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:viora/app.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/features/user/presentation/providers/user_provider.dart';
import 'package:viora/presentation/providers/font_size_provider.dart';
import 'package:viora/presentation/providers/locale_provider.dart';
import 'package:viora/presentation/providers/theme_provider.dart';

// Conditional imports for platform-specific code
import 'core/platform/platform_stub.dart'
    if (dart.library.io) 'core/platform/platform_io.dart';

Future<(bool, SharedPreferences)> _initializeServices() async {
  late SharedPreferences prefs;
  bool hasSeenOnboarding = false;
  try {
    // Initialize SharedPreferences
    // Must be called first to allow other services to use it
    prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    debugPrint('Service Initializer: Onboarding status: $hasSeenOnboarding');

    // Initialize SQLite for desktop platforms
    if (!kIsWeb) {
      if (Platform.isDesktop) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        debugPrint('Service Initializer: SQLite FFI initialized for desktop.');
      }
    }

    // Initialize Supabase
    final supabaseInitialized = await SupabaseConfig.initialize();
    if (!supabaseInitialized) {
      debugPrint(
          'Service Initializer Error: Supabase initialization failed. Last error: ${SupabaseConfig.lastError}');
      // Consider showing a specific error message to the user or allow retry
    } else {
      final session = SupabaseConfig.client.auth.currentSession;
      debugPrint(
          'Service Initializer: Supabase initialized successfully. Current session: ${session?.user.id}');
    }
  } catch (e, stackTrace) {
    debugPrint('Service Initializer Error: An unexpected error occurred during service initialization: $e\n$stackTrace');
    // Consider showing a generic error message to the user
    // Ensure prefs is initialized even if an error occurs before its assignment,
    // though in this flow it's the first async call.
    prefs = await SharedPreferences.getInstance(); // Fallback, though likely already set.
  }
  return (hasSeenOnboarding, prefs);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services and get onboarding status and prefs
  final (bool hasSeenOnboarding, SharedPreferences prefs) = await _initializeServices();

  // Initialize database and repositories
  // Note: Desktop SQLite FFI initialization is now in _initializeServices
  Database? db;
  if (!kIsWeb && Platform.isDesktop) { // Ensure db is only opened on desktop after ffi init
    try {
      db = await databaseFactoryFfi.openDatabase('viora.db');
      debugPrint('Main: SQLite database opened successfully for desktop.');
    } catch (e) {
      debugPrint('Main Error: Error opening SQLite database for desktop: $e');
    }
  }
  final userProvider = UserProvider(db); // db can be null for non-desktop

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
