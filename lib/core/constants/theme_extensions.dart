import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ThemeExtensions on ThemeData {
  // Gradients
  LinearGradient get sunsetGradient => AppTheme.sunsetGradient;
  LinearGradient get nightGradient => AppTheme.nightGradient;

  // Animation durations
  Duration get themeChangeDuration => AppTheme.themeChangeDuration;

  // Additional colors
  Color get sunsetOrange => AppTheme.metallicGold;
  Color get twilightPurple => AppTheme.deepBrown;
  Color get dawnPink => AppTheme.agedBeige;
  Color get nightBlue => AppTheme.geometricBlack;

  // Theme-specific colors
  Color get primaryBackground => brightness == Brightness.light
      ? AppTheme.lightBackground
      : AppTheme.darkBackground;

  Color get primarySurface => brightness == Brightness.light
      ? AppTheme.lightSurface
      : AppTheme.darkSurface;

  Color get primaryText =>
      brightness == Brightness.light ? AppTheme.lightText : AppTheme.darkText;

  // Custom styles
  BoxDecoration get cardDecoration => BoxDecoration(
        color: primarySurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.geometricBlack.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.metallicGold.withOpacity(0.3),
          width: 1,
        ),
      );

  BoxDecoration get gradientDecoration => BoxDecoration(
        gradient: brightness == Brightness.light
            ? AppTheme.sunsetGradient
            : AppTheme.nightGradient,
      );

  // Custom text styles
  TextStyle get futuristicTitle => textTheme.headlineMedium!.copyWith(
        color: brightness == Brightness.light ? Colors.black : Colors.white,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      );

  TextStyle get futuristicSubtitle => textTheme.titleMedium!.copyWith(
        color: brightness == Brightness.light
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      );

  TextStyle get futuristicBody => textTheme.bodyLarge!.copyWith(
        color: brightness == Brightness.light ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );
}
