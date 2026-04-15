import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF7F77DD);
  static const accentColor = Color(0xFF9F8FEF);
  static const backgroundColor = Color(0xFF141414);
  static const surfaceColor = Color(0xFF1E1E1E);
  static const cardColor = Color(0xFF252525);
  static const textPrimary = Color(0xFFF0ECE4);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textMuted = Color(0xFF555555);

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
      ),
    );
  }
}