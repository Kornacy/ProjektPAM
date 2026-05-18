import 'package:flutter/material.dart';

class AppTheme {
  static const Color secondaryAccent = Color(0xFF2E7D32);

  static ThemeData theme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
        secondary: secondaryAccent,
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: brightness == Brightness.dark ? 2 : 1,
      ),
    );
  }

  static ThemeData light(Color seedColor) =>
      theme(brightness: Brightness.light, seedColor: seedColor);

  static ThemeData dark(Color seedColor) =>
      theme(brightness: Brightness.dark, seedColor: seedColor);
}
