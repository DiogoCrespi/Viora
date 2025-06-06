import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o arquivo .env
  await dotenv.load();

  // Inicializa o Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Tenta fazer uma consulta simples
  try {
    final response =
        await Supabase.instance.client.from('users').select().limit(1);

    print('Conexão com Supabase bem sucedida!');
    print('Resposta: $response');
  } catch (e) {
    print('Erro ao conectar com Supabase:');
    print(e.toString());
  }
}
