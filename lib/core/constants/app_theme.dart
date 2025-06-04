import 'package:flutter/material.dart';

class AppTheme {
  // Sunset-inspired color palette
  static const Color deepBrown = Color(0xFF2C1810);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color agedBeige = Color(0xFFF5E6D3);
  static const Color geometricBlack = Color(0xFF1A1A1A);

  // Additional color variations
  static const Color sunsetOrange = Color(0xFFD4AF37);
  static const Color twilightPurple = Color(0xFF2C1810);
  static const Color dawnPink = Color(0xFFF5E6D3);
  static const Color nightBlue = Color(0xFF1A1A1A);

  // Gradients
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Colors.white, metallicGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [geometricBlack, deepBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Animation durations
  static const Duration themeChangeDuration = Duration(milliseconds: 300);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5E6D3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2C1810);
  static const Color darkText = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepBrown,
      primary: deepBrown,
      secondary: metallicGold,
      onSurface: Colors.black,
      onBackground: Colors.black,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Colors.black,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
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
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: geometricBlack,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: metallicGold,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}
