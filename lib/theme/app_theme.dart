import 'package:flutter/material.dart';

/// ธีมกลางของแอป — มินิมอล สีขาวสะอาด มีจุดเน้นสีเขียวมะกอกอุ่น ๆ
/// รองรับทั้งโหมดสว่างและมืด
class AppTheme {
  // ---- โหมดสว่าง ----
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF4A6B4D); // เขียวมะกอกหม่น
  static const Color primaryLight = Color(0xFFE8EEE6);
  static const Color textPrimary = Color(0xFF2B2B26);
  static const Color textSecondary = Color(0xFF8A8A82);
  static const Color divider = Color(0xFFEDEDE8);
  static const Color accentRed = Color(0xFFC4564A);

  // ---- โหมดมืด ----
  static const Color backgroundDark = Color(0xFF15170F);
  static const Color surfaceDark = Color(0xFF1F2219);
  static const Color primaryDark = Color(0xFF8FBB8F);
  static const Color primaryLightDark = Color(0xFF2A3324);
  static const Color textPrimaryDark = Color(0xFFEDEDE6);
  static const Color textSecondaryDark = Color(0xFFA3A79A);
  static const Color dividerDark = Color(0xFF2E3226);
  static const Color accentRedDark = Color(0xFFE0837A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      dividerColor: divider,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        surface: surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      dividerColor: dividerDark,
    );
  }

  // ---- helper แบบ context-aware สำหรับ widget ที่ต้องสลับสีเอง ----
  static Color bg(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? backgroundDark : background;
  static Color surf(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? surfaceDark : surface;
  static Color prim(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? primaryDark : primary;
  static Color primLight(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? primaryLightDark : primaryLight;
  static Color txtPrimary(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? textPrimaryDark : textPrimary;
  static Color txtSecondary(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? textSecondaryDark : textSecondary;
  static Color div(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? dividerDark : divider;
  static Color accRed(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? accentRedDark : accentRed;
}
