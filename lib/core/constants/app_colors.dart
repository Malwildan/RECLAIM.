import 'package:flutter/material.dart';

/// App color constants used throughout the application.
/// Using a centralized color palette for consistency.
abstract class AppColors {
  // Background colors
  static const Color background = Color(0xFF050505);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color cardBackgroundLight = Color(0xFF222222);
  static const Color inputBackground = Color(0xFF222222);

  // Accent colors
  static const Color accentGreen = Color(0xFFB4F8C8);
  static const Color accentTeal = Color(0xFF64FFDA);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color accentPurple = Color(0xFFAA00FF);

  // Danger/Warning colors
  static const Color dangerRed = Color(0xFFFF4B4B);
  static const Color warningOrange = Color(0xFFFF9800);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF666666);

  // Border colors
  static const Color borderLight = Color(0xFF333333);
  static Color borderSubtle = Colors.white.withOpacity(0.05);
}
