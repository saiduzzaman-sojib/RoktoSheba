import 'package:flutter/material.dart';

class AppColors {
  static const red = Color(0xFFB3322F);
  static const redLight = Color(0xFFE0524B);
  static const redDark = Color(0xFF8A1F22);
  static const ink = Color(0xFF1E1B22);
  static const inkSoft = Color(0xFF34283A);
  static const grey = Color(0xFF6B6470);
  static const green = Color(0xFF0B6B5C);
  static const border = Color(0xFFEADFD5);
  static const bgTop = Color(0xFFFFF9F4);
  static const bgBottom = Color(0xFFF6E9E0);

  static const redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [redLight, red, redDark],
    stops: [0, .55, 1],
  );
  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [inkSoft, ink, Color(0xFF5A1D26)],
    stops: [0, .55, 1],
  );
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );
}