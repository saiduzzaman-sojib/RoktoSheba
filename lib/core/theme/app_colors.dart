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
extension AppTheming on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surface => isDark ? const Color(0xFF211C26) : Colors.white;
  Color get surfaceAlt =>
      isDark ? const Color(0xFF2A2330) : const Color(0xFFFFF6EF);
  Color get textMain => isDark ? const Color(0xFFF4EEF2) : AppColors.ink;
  Color get textMuted => isDark ? const Color(0xFFB5ABBA) : AppColors.grey;
  Color get line => isDark ? const Color(0xFF3A3140) : AppColors.border;

  LinearGradient get bgGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17131A), Color(0xFF0F0C12)],
        )
      : AppColors.bgGradient;
}