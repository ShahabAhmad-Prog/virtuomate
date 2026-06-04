import 'package:flutter/material.dart';

/// Tokens aligned with `virtuomate-mvp/constants/virtuomate-theme.ts`
class VirtuoMvpColors {
  VirtuoMvpColors._();

  static const Color bg0 = Color(0xFF09051A);
  static const Color bg1 = Color(0xFF140A2A);
  static const Color bg2 = Color(0xFF1B0B3A);
  /// Opaque card/button surface (avoid translucent white on Material — renders as white on device).
  static const Color surface = Color(0xFF221547);
  static const Color surface2 = Color(0xFF2E1D58);
  /// Inset fields and list tiles.
  static const Color inputFill = Color(0xFF1A1034);
  static const Color stroke = Color(0xFF4A3A7A);
  static const Color stroke2 = Color(0xFF5E4D94);
  static const Color text = Color(0xFFEAF0FF);
  static const Color textMuted = Color.fromRGBO(234, 240, 255, 0.72);
  static const Color textFaint = Color.fromRGBO(234, 240, 255, 0.55);
  static const Color cyan = Color(0xFF3BE7FF);
  static const Color blue = Color(0xFF4A7DFF);
  static const Color purple = Color(0xFF8B5CFF);
  static const Color magenta = Color(0xFFD05CFF);
  static const Color green = Color(0xFF3CFFB2);
  static const Color yellow = Color(0xFFFFD166);
  static const Color red = Color(0xFFFF5C7C);
  static const Color amber = Color(0xFFFFB74D);
  static const Color primaryTextOnPurple = Color(0xFF0B0720);
}

class VirtuoMvpRadii {
  VirtuoMvpRadii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
}

class VirtuoMvpSpacing {
  VirtuoMvpSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}
