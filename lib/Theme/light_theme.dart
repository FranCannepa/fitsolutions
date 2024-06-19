import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.white,
      onPrimary: const Color(0xff844A10),
      primary: const Color(0xFFFF9800),
      secondary: const Color(0xFF1c1d1a),
      tertiary: const Color(0xFFFF9800).withOpacity(0.7),
    ));
