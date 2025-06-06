import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load();

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      debug: true,
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );

    // Verificar e restaurar a sessão
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint(
        'SupabaseConfig: Current session after init: ${session?.user.id}');
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
}
