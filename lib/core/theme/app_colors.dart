import 'package:flutter/material.dart';

/// Centralized color palette for OTT Stream.
/// Following Material Design 3 naming conventions.
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primaryRed = Color(0xFFE50914);
  static const Color secondaryBlue = Color(0xFF54B9FF);

  // Dark Scheme
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFAAAAAA);

  // Light Scheme
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F0F0F);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);

  // Status Colors
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}
