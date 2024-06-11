import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.white,
      primary: const Color(0xFFFF9800),
      secondary: const Color(0xFF403934),
      tertiary: const Color(0xFFFF9800).withOpacity(0.7),
    ));
