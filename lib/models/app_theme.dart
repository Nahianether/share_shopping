import 'package:flutter/material.dart';

enum ThemeType { light, dark }

class AppTheme {
  final ThemeType type;

  AppTheme({required this.type});

  bool get isDark => type == ThemeType.dark;

  // Light theme colors
  static const lightPrimary = Color(0xFFFF9066);
  static const lightSecondary = Color(0xFFFF6B35);
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Colors.white;
  static const lightText = Color(0xFF212121);
  static const lightTextSecondary = Color(0xFF757575);

  // Dark theme colors
  static const darkPrimary = Color(0xFFFF9066);
  static const darkSecondary = Color(0xFFFF6B35);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFFB0B0B0);

  // Gradient colors
  List<Color> get gradientColors => isDark
      ? [const Color(0xFFFF9066), const Color(0xFFFF6B35)]
      : [const Color(0xFFFF9066), const Color(0xFFFF6B35)];

  Color get backgroundColor => isDark ? darkBackground : lightBackground;
  Color get surfaceColor => isDark ? darkSurface : lightSurface;
  Color get textColor => isDark ? darkText : lightText;
  Color get textSecondaryColor => isDark ? darkTextSecondary : lightTextSecondary;
  Color get primaryColor => isDark ? darkPrimary : lightPrimary;
  Color get secondaryColor => isDark ? darkSecondary : lightSecondary;

  ThemeData get themeData => isDark ? _darkTheme : _lightTheme;

  static ThemeData get _lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        cardColor: lightSurface,
        brightness: Brightness.light,
      );

  static ThemeData get _darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimary,
          brightness: Brightness.dark,
          surface: darkSurface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkSurface,
        brightness: Brightness.dark,
      );

  static AppTheme fromString(String? themeString) {
    if (themeString == 'dark') {
      return AppTheme(type: ThemeType.dark);
    }
    return AppTheme(type: ThemeType.light);
  }

  @override
  String toString() => type == ThemeType.dark ? 'dark' : 'light';
}
