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

  // ---- Premium dark palette (neutral graphite) ----
  static const dBgTop = Color(0xFF121214);
  static const dBgBottom = Color(0xFF09090B);
  static const dSurface = Color(0xFF18181C);
  static const dSurfaceAlt = Color(0xFF202025);
  static const dText = Color(0xFFF4F4F5);
  static const dMuted = Color(0xFFA1A1AA);
  static const dLine = Color(0xFF2C2C32);
  static const dAccent = Color(0xFFF2584F);

  /// Hero card in dark mode (wine tint)
  static const dHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B1E26), Color(0xFF1B1315), Color(0xFF4F1B22)],
    stops: [0, .55, 1],
  );
}

extension AppTheming on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surface => isDark ? AppColors.dSurface : Colors.white;
  Color get surfaceAlt =>
      isDark ? AppColors.dSurfaceAlt : const Color(0xFFFFF6EF);
  Color get textMain => isDark ? AppColors.dText : AppColors.ink;
  Color get textMuted => isDark ? AppColors.dMuted : AppColors.grey;
  Color get line => isDark ? AppColors.dLine : AppColors.border;
  Color get bgBase => isDark ? AppColors.dBgTop : Colors.white;
  Color get accent => isDark ? AppColors.dAccent : AppColors.red;

  LinearGradient get bgGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.dBgTop, AppColors.dBgBottom],
        )
      : AppColors.bgGradient;
}