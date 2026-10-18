import 'package:flutter/material.dart';

abstract final class AppColors {
  static const steps = Color(0xFF287A48);
  static const calories = Color(0xFFC13D32);
  static const water = Color(0xFF2467B2);
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF287A48)),
  scaffoldBackgroundColor: const Color(0xFFF6F7F8),
  appBarTheme: const AppBarTheme(centerTitle: false),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
);
