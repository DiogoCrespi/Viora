import 'package:flutter/material.dart';

class AppTheme {
  // Sunset-inspired color palette
  static const Color deepBrown = Color(0xFF2C1810);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color agedBeige = Color(0xFFF5E6D3);
  static const Color geometricBlack = Color(0xFF1A1A1A);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2C1810);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2F2F2F);
  static const Color darkText = Color(0xFFE8D5B5);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepBrown,
      primary: deepBrown,
      secondary: metallicGold,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBrown,
      foregroundColor: metallicGold,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: metallicGold,
        foregroundColor: deepBrown,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepBrown,
      primary: deepBrown,
      secondary: metallicGold,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: geometricBlack,
      foregroundColor: metallicGold,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: metallicGold,
        foregroundColor: geometricBlack,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}
