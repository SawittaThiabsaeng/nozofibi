import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  // =============================
  // 🎨 COLORS
  // =============================

  // Accent
  static const Color primary = AppTokens.brand;
  static const Color secondary = AppTokens.brandSoft;
  static const Color creamBackground = Color(0xFFF8F6F1);

  // Light mode
  static const Color backgroundLight = AppTokens.lightBackground;
  static const Color textDark = AppTokens.lightTextPrimary;
  static const Color inputLight = AppTokens.lightSurfaceSubtle;

  // Dark mode (โทนเดียวกับภาพ)
  static const Color backgroundDark = AppTokens.darkBackground;
  static const Color backgroundDark2 = Color(0xFF1A1F3A);
  static const Color cardDark = AppTokens.darkSurface;
  static const Color inputDark = AppTokens.darkSurfaceSubtle;

  static const Color textMuted = AppTokens.lightTextSecondary;

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

  static ThemeData getTheme({required bool isDarkMode}) => ThemeData(
        fontFamily: AppTokens.fontFamily,
        useMaterial3: true,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        colorScheme: AppTokens.colorScheme(isDark: isDarkMode),
        cardColor: isDarkMode ? cardDark : Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? Colors.transparent : backgroundLight,
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF7C3AED);
              }
              return primary;
            }),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: const WidgetStatePropertyAll(Color(0x1FFFFFFF)),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return 1;
              }
              if (states.contains(WidgetState.hovered)) {
                return 5;
              }
              return 3;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            foregroundColor: WidgetStatePropertyAll(
              isDarkMode
                  ? AppTokens.darkTextPrimary
                  : AppTokens.lightTextPrimary,
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return const BorderSide(color: AppTokens.brand, width: 2);
              }
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(
                  color: isDarkMode
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  width: 1,
                );
              }
              return BorderSide(
                color: isDarkMode
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                width: 1.5,
              );
            }),
            overlayColor: const WidgetStatePropertyAll(Color(0x12000000)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: isDarkMode ? cardDark : Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            side: BorderSide(
              color: isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.black87 : textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            color: isDarkMode ? Colors.black87 : textDark,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          modalBackgroundColor: Colors.white,
        ),
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Colors.white,
          dialBackgroundColor: Color(0xFFF8FAFC),
        ),
        chipTheme: ChipThemeData(
          backgroundColor:
              isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
          selectedColor: primary,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white : textDark,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color:
                isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor:
              isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
          hintStyle: TextStyle(
            color:
                isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide(
              color: isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: const BorderSide(color: AppTokens.brand, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: const BorderSide(color: AppTokens.danger, width: 1.4),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide(
              color: isDarkMode
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFE2E8F0),
            ),
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
