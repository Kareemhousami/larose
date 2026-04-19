import 'package:flutter/material.dart';

/// Legacy theme kept for any older screens that still rely on the Ma Rose palette.
ThemeData buildMaRoseTheme() {
  const ivory = Color(0xFFF8F6F7);
  const rose = Color(0xFFC91D73);
  const plum = Color(0xFF211119);

  return ThemeData(
    scaffoldBackgroundColor: ivory,
    colorScheme: const ColorScheme.light(
      primary: rose,
      secondary: rose,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: plum,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Georgia',
        color: plum,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF5E5360),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF8A7B82),
      ),
    ),
    useMaterial3: true,
  );
}
