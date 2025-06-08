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
      debugPrint('SupabaseConfig: Supabase não está inicializado, tentando inicializar...');
      return await initialize();
    }

    try {
      // Tenta fazer uma consulta simples para verificar a conexão
      await client.from('users').select('count').limit(1);
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('SupabaseConfig: Erro ao verificar conexão: $e');
      return false;
    }
  }

  static Future<bool> initialize() async {
    if (_initialized) {
      debugPrint('SupabaseConfig: Supabase já está inicializado');
      return true;
    }

    try {
      await dotenv.load();

      _supabaseUrl = dotenv.env['SUPABASE_URL'];
      _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (_supabaseUrl == null || _supabaseUrl!.isEmpty || _supabaseAnonKey == null || _supabaseAnonKey!.isEmpty) {
        throw Exception('Credenciais do Supabase não encontradas no arquivo .env');
      }

      await Supabase.initialize(
        url: _supabaseUrl!,
        anonKey: _supabaseAnonKey!,
      );
      
      _initialized = true;
      _lastError = null;
      debugPrint('SupabaseConfig: Supabase inicializado com sucesso');
      
      final session = client.auth.currentSession;
      debugPrint('SupabaseConfig: Current session after init: ${session?.user.id}');
      
      return true;
    } catch (e) {
      _initialized = false;
      _lastError = e.toString();
      debugPrint('SupabaseConfig: Erro durante inicialização: $e');
      return false;
    }
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase não foi inicializado. Chame SupabaseConfig.initialize() primeiro.');
    }
    return Supabase.instance.client;
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('SupabaseConfig: Erro durante signOut: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (!await checkConnection()) {
        throw Exception('Sem conexão com o Supabase');
      }
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _lastError = e.toString();
      debugPrint('SupabaseConfig: Erro durante signIn: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      if (!await checkConnection()) {
        throw Exception('Sem conexão com o Supabase');
      }
      return await client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      _lastError = e.toString();
      debugPrint('SupabaseConfig: Erro durante signUp: $e');
      rethrow;
    }
  }
}
