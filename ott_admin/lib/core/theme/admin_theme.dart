import 'package:flutter/material.dart';
import 'admin_colors.dart';
import 'admin_typography.dart';

class AdminTheme {
  AdminTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AdminColors.primary,
      scaffoldBackgroundColor: AdminColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primary,
        surface: AdminColors.surfaceDark,
        background: AdminColors.backgroundDark,
      ),
      textTheme: AdminTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.surfaceDark,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AdminColors.primary,
      scaffoldBackgroundColor: AdminColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AdminColors.primary,
        surface: AdminColors.surfaceLight,
        background: AdminColors.backgroundLight,
      ),
      textTheme: AdminTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.surfaceLight,
        elevation: 0,
      ),
    );
  }
}
