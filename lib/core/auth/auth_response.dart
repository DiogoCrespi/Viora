import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAuthResponse {
  final bool success;
  final String? error;
  final User? user;
  final Session? session;

  CustomAuthResponse({
    required this.success,
    this.error,
    this.user,
    this.session,
  });
}
