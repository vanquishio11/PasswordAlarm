import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgTop = Color(0xFF0B0F18);
  static const Color bgBottom = Color(0xFF070A10);

  static const Color panel = Color(0xFF151B27);
  static const Color panel2 = Color(0xFF111827);
  static const Color stroke = Color(0xFF2A3242);

  static const Color textPrimary = Color(0xFFE9EEF7);
  static const Color textMuted = Color(0xFF8A96AD);

  static const Color accent = Color(0xFFF6B21A); // warm yellow
  static const Color accentSoft = Color(0x33F6B21A);

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: panel,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgBottom,
      fontFamily: null,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 52, fontWeight: FontWeight.w300),
        headlineMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }
}
