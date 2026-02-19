import 'package:flutter/material.dart';

class AppTheme {
  // สีหลักจาก Tailwind/React
  static const Color primary = Color(0xFFA78BFA);   // Purple 400
  static const Color secondary = Color(0xFF60A5FA); // Blue 400
  static const Color backgroundLight = Color(0xFFFDFCFE);
  static const Color backgroundDark = Color(0xFF0B0F1A);
  static const Color creamBackground = Color(0xFFFDFCFE); // Alias for backgroundLight
  
  static const Color cardDark = Color(0xCC1A1C26);
  static const Color inputLight = Color(0xFFF9FAFF);
  static const Color inputDark = Color(0xFF12141D);
  
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textDark = Color(0xFF1E293B);  // Slate 800

  // Typography สไตล์ React
  static TextStyle get h1 => const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.5);
  static TextStyle get h2 => const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
  static TextStyle get caption => const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: textMuted);
  static TextStyle get bodyBold => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark);

  static ThemeData getTheme(bool isDarkMode) => ThemeData(
      fontFamily: 'Plus Jakarta Sans', // อย่าลืมเพิ่มใน pubspec.yaml
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      textTheme: TextTheme(
        headlineLarge: h1.copyWith(color: isDarkMode ? Colors.white : textDark),
        headlineMedium: h2.copyWith(color: isDarkMode ? Colors.white : textDark),
        bodyMedium: TextStyle(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : textDark),
      ),
    );
}
