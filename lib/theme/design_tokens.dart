import 'package:flutter/material.dart';

class AppTokens {
  const AppTokens._();

  static const String fontFamily = 'PlusJakartaSans';

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 40;

  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionMedium = Duration(milliseconds: 240);
  static const Duration motionSlow = Duration(milliseconds: 360);
  static const Duration motionExtraSlow = Duration(milliseconds: 480);

  static const Color brand = Color(0xFF8B5CF6);
  static const Color brandSoft = Color(0xFFC4B5FD);
  static const Color info = Color(0xFF60A5FA);
  static const Color accentPink = Color(0xFFDB2777);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFCBD5E1);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceSubtle = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF475569);

  static ColorScheme colorScheme({required bool isDark}) {
    if (isDark) {
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: brand,
        onPrimary: Colors.white,
        secondary: brandSoft,
        onSecondary: Color(0xFF1E1B4B),
        error: danger,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
      );
    }

    return const ColorScheme(
      brightness: Brightness.light,
      primary: brand,
      onPrimary: Colors.white,
      secondary: brandSoft,
      onSecondary: Color(0xFF1E1B4B),
      error: danger,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
    );
  }
}
