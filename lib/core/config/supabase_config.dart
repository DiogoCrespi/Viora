import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static bool _initialized = false;
  static String? _lastError;
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;

  static bool get isInitialized => _initialized;
  static String? get lastError => _lastError;

  static Future<bool> checkConnection() async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: checkConnection: Supabase not initialized, attempting to initialize...');
      }
      return await initialize(); // Initialize will set its own _lastError
    }

    try {
      // Tenta fazer uma consulta simples para verificar a conexão
      await client.from('users').select('count').limit(1);
      _lastError = null; // Clear last error on successful check
      if (kDebugMode) {
        debugPrint('SupabaseConfig: checkConnection: Connection successful.');
      }
      return true;
    } catch (e, stackTrace) {
      _lastError = e.toString();
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: checkConnection: Error verifying connection: $e\nStackTrace: $stackTrace');
      }
      return false;
    }
  }

  static Future<bool> initialize() async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('SupabaseConfig: initialize: Supabase already initialized.');
      }
      return true;
    }

    try {
      if (kDebugMode) {
        debugPrint('SupabaseConfig: initialize: Attempting to load .env file.');
      }
      await dotenv.load(fileName: ".env");

      _supabaseUrl = dotenv.env['SUPABASE_URL'];
      _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (_supabaseUrl == null ||
          _supabaseUrl!.isEmpty ||
          _supabaseAnonKey == null ||
          _supabaseAnonKey!.isEmpty) {
        _lastError =
            'Supabase credentials not found or empty in .env file.';
        if (kDebugMode) {
          debugPrint('SupabaseConfig: initialize: Error: $_lastError');
        }
        throw Exception(_lastError);
      }
      if (kDebugMode) {
        debugPrint('SupabaseConfig: initialize: .env file loaded successfully.');
      }

      await Supabase.initialize(
        url: _supabaseUrl!,
        anonKey: _supabaseAnonKey!,
        debug: kDebugMode, // Enable Supabase internal debugging in debug mode
      );

      _initialized = true;
      _lastError = null; // Clear last error on successful initialization
      if (kDebugMode) {
        debugPrint('SupabaseConfig: initialize: Supabase initialized successfully.');
        debugPrint('SupabaseConfig: initialize: URL: $_supabaseUrl');
        debugPrint(
            'SupabaseConfig: initialize: Key: ${_supabaseAnonKey!.substring(0, 5)}...');
      }

      final session = client.auth.currentSession;
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: initialize: Current session after init: ${session?.user.id}');
      }

      return true;
    } catch (e, stackTrace) {
      _initialized = false;
      // Avoid overwriting a more specific error message from the checks above
      if (_lastError == null || _lastError!.isEmpty) {
        _lastError = e.toString();
      }
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: initialize: Error during initialization: $e\nStackTrace: $stackTrace');
      }
      return false;
    }
  }

  static SupabaseClient get client {
    if (!_initialized) {
      // This is a programming error, should not happen if initialize is called correctly.
      const String errorMsg =
          'SupabaseConfig: client: Supabase not initialized. Call SupabaseConfig.initialize() first.';
      if (kDebugMode) {
        debugPrint(errorMsg);
      }
      throw Exception(errorMsg);
    }
    return Supabase.instance.client;
  }

  static Future<void> signOut() async {
    if (!_initialized) {
      _lastError =
          'Supabase not initialized. Cannot sign out.';
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signOut: Error: $_lastError');
      }
      throw Exception(_lastError);
    }
    try {
      await client.auth.signOut();
      _lastError = null; // Clear last error on successful sign out
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signOut: User signed out successfully.');
      }
    } catch (e, stackTrace) {
      _lastError = e.toString();
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: signOut: Error during sign out: $e\nStackTrace: $stackTrace');
      }
      rethrow; // Rethrow to allow calling code to handle UI updates or further actions
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
       _lastError =
          'Supabase not initialized. Cannot sign in.';
       if (kDebugMode) {
        debugPrint('SupabaseConfig: signIn: Error: $_lastError');
       }
      throw Exception(_lastError);
    }
    try {
      // checkConnection call removed as per previous discussion that signInWithPassword will do its own check.
      // if (!await checkConnection()) {
      //   _lastError = 'No connection to Supabase. Cannot sign in.';
      //   debugPrint('SupabaseConfig: signIn: Error: $_lastError');
      //   throw Exception(_lastError);
      // }
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signIn: Attempting to sign in user $email.');
      }
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _lastError = null; // Clear last error on successful sign in
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signIn: User $email signed in successfully.');
      }
      return response;
    } catch (e, stackTrace) {
      _lastError = e.toString();
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: signIn: Error during sign in for user $email: $e\nStackTrace: $stackTrace');
      }
      rethrow;
    }
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
       _lastError =
          'Supabase not initialized. Cannot sign up.';
       if (kDebugMode) {
        debugPrint('SupabaseConfig: signUp: Error: $_lastError');
       }
      throw Exception(_lastError);
    }
    try {
      // checkConnection call removed.
      // if (!await checkConnection()) {
      //  _lastError = 'No connection to Supabase. Cannot sign up.';
      //  debugPrint('SupabaseConfig: signUp: Error: $_lastError');
      //  throw Exception(_lastError);
      // }
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signUp: Attempting to sign up user $email.');
      }
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      _lastError = null; // Clear last error on successful sign up
      if (kDebugMode) {
        debugPrint('SupabaseConfig: signUp: User $email signed up successfully (pending confirmation if applicable).');
      }
      return response;
    } catch (e, stackTrace) {
      _lastError = e.toString();
      if (kDebugMode) {
        debugPrint(
            'SupabaseConfig: signUp: Error during sign up for user $email: $e\nStackTrace: $stackTrace');
      }
      rethrow;
    }
  }
}
