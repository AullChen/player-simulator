import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF071A2B);
  static const navySoft = Color(0xFF102B3E);
  static const pitch = Color(0xFF10B981);
  static const pitchDark = Color(0xFF087F5B);
  static const gold = Color(0xFFD6A756);
  static const mist = Color(0xFFF2F5F3);
  static const ink = Color(0xFF13252F);
  static const muted = Color(0xFF63747D);
  static const line = Color(0xFFDCE4E1);
  static const danger = Color(0xFFB23A48);
}

abstract final class AppTheme {
  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.pitch,
      brightness: Brightness.light,
      primary: AppColors.pitchDark,
      secondary: AppColors.gold,
      surface: Colors.white,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.mist,
      fontFamilyFallback: const [
        'Microsoft YaHei',
        'PingFang SC',
        'sans-serif',
      ],
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 42,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.6,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 30,
          height: 1.1,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: AppColors.ink),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: AppColors.muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pitchDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.pitchDark, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),
    );
  }
}
