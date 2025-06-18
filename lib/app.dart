import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/presentation/providers/theme_provider.dart';
import 'package:viora/presentation/providers/font_size_provider.dart';
import 'package:viora/presentation/providers/locale_provider.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/features/auth/presentation/pages/login_screen.dart';
import 'package:viora/routes.dart';

class VioraApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const VioraApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
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
            if (kDebugMode) {
              debugPrint(
                  'VioraApp: Generating route ${settings.name} with session: ${session?.user.id}');
            }

            // Lógica de autenticação para rotas protegidas
            if (_isProtectedRoute(settings.name) && session == null) {
              if (kDebugMode) {
                debugPrint(
                    'VioraApp: Redirecting to login (protected route without session)');
              }
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
