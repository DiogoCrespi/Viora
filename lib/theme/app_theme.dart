import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sunset-inspired color palette
  static const Color deepBrown = Color(0xFF2C1810);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color agedBeige = Color(0xFFE8D5B5);
  static const Color geometricBlack = Color(0xFF1A1A1A);
  static const Color graphite = Color(0xFF2F2F2F);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2C1810);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2F2F2F);
  static const Color darkText = Color(0xFFE8D5B5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: metallicGold,
      secondary: deepBrown,
      surface: lightSurface,
      background: lightBackground,
      error: Colors.red.shade900,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(
        color: lightText,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.orbitron(
        color: lightText,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.exo2(color: lightText, fontSize: 16),
      bodyMedium: GoogleFonts.exo2(color: lightText, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: lightText,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: metallicGold,
        foregroundColor: deepBrown,
        textStyle: GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: metallicGold,
      secondary: agedBeige,
      surface: darkSurface,
      background: darkBackground,
      error: Colors.red.shade300,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(
        color: darkText,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.orbitron(
        color: darkText,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.exo2(color: darkText, fontSize: 16),
      bodyMedium: GoogleFonts.exo2(color: darkText, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: metallicGold,
        foregroundColor: deepBrown,
        textStyle: GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
