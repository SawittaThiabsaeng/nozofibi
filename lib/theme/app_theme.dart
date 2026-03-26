import 'package:flutter/material.dart';

class AppTheme {
  // =============================
  // 🎨 COLORS
  // =============================

  // Accent
  static const Color primary = Color(0xFFA78BFA);   // Purple glow
  static const Color secondary = Color(0xFF60A5FA); // Blue accent
  static const Color creamBackground = Color(0xFFF8F6F1);
  
  // Light mode
  static const Color backgroundLight = Color(0xFFFDFCFE);
  static const Color textDark = Color(0xFF1E293B);
  static const Color inputLight = Color(0xFFF9FAFF);

  // Dark mode (โทนเดียวกับภาพ)
  static const Color backgroundDark = Color(0xFF0B1020);
  static const Color backgroundDark2 = Color(0xFF1A1F3A);
  static const Color cardDark = Color(0xFF14182B);
  static const Color inputDark = Color(0xFF12141D);

  static const Color textMuted = Color(0xFF94A3B8);

  // =============================
  // 🌈 GRADIENT (ใช้ห่อ Scaffold)
  // =============================

  static const BoxDecoration darkGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        backgroundDark,
        backgroundDark2,
      ],
    ),
  );

  // =============================
  // ✍️ TYPOGRAPHY
  // =============================

  static TextStyle get h1 => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      );

  static TextStyle get h2 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
        color: textMuted,
      );

  static TextStyle get bodyBold => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  // =============================
  // 🌙 THEME BUILDER
  // =============================

  static ThemeData getTheme(bool isDarkMode) {
    return ThemeData(
      fontFamily: 'Plus Jakarta Sans',
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,

      scaffoldBackgroundColor:
          isDarkMode ? backgroundDark : backgroundLight,

      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: isDarkMode ? cardDark : Colors.white,
        background: isDarkMode ? backgroundDark : backgroundLight,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDarkMode ? Colors.white : textDark,
        onBackground: isDarkMode ? Colors.white : textDark,
        onError: Colors.white,
      ),

      cardColor: isDarkMode ? cardDark : Colors.white,

      appBarTheme: AppBarTheme(
        backgroundColor:
            isDarkMode ? Colors.transparent : backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : textDark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : textDark,
        ),
      ),

      textTheme: TextTheme(
        headlineLarge:
            h1.copyWith(color: isDarkMode ? Colors.white : textDark),
        headlineMedium:
            h2.copyWith(color: isDarkMode ? Colors.white : textDark),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : textDark,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.5);
          }
          return Colors.grey.shade400;
        }),
      ),
    );
  }

  // =============================
  // ✨ GLOW EFFECT (ใช้กับปุ่ม)
  // =============================

  static BoxDecoration glowButtonDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.5),
        blurRadius: 20,
        spreadRadius: 1,
      ),
    ],
  );
}