// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// High-contrast theme tailored for accessibility, low-vision, and eyes-free cockpit use.
class AppTheme {
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color beaconYellow = Color(0xFFFFD600);
  static const Color darkSurface = Color(0xFF121212);
  static const Color subtleGray = Color(0xFF2C2C2C);
  static const Color errorRed = Color(0xFFFF3D00);

  static ThemeData get highContrastDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,
      colorScheme: const ColorScheme.dark(
        primary: beaconYellow,
        onPrimary: pureBlack,
        surface: pureBlack,
        onSurface: pureWhite,
        error: errorRed,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: beaconYellow,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: pureWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: pureWhite,
          fontSize: 18,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: beaconYellow,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}