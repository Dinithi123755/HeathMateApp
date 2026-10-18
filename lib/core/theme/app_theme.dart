import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF087F71);
  static const ink = Color(0xFF19342F);
  static const muted = Color(0xFF5D726D);
  static const background = Color(0xFFF3F7F5);
  static const line = Color(0xFFDCE7E2);
  static const steps = Color(0xFF087F71);
  static const calories = Color(0xFFBD5035);
  static const water = Color(0xFF326DC3);
}

ThemeData appTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outlineVariant: AppColors.line,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -.4,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        height: 1.45,
        color: AppColors.ink,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIconColor: AppColors.primary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFFD9EEE8),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
