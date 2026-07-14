import 'package:flutter/material.dart';

/// ธีมกลางของแอป — มินิมอล สีขาวสะอาด มีจุดเน้นสีเขียวมะกอกอุ่น ๆ
class AppTheme {
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF4A6B4D); // เขียวมะกอกหม่น
  static const Color primaryLight = Color(0xFFE8EEE6);
  static const Color textPrimary = Color(0xFF2B2B26);
  static const Color textSecondary = Color(0xFF8A8A82);
  static const Color divider = Color(0xFFEDEDE8);
  static const Color accentRed = Color(0xFFC4564A);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
        background: background,
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
}
