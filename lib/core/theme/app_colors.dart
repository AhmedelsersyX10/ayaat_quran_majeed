import 'package:flutter/material.dart';

/// Design tokens for colors used throughout the app.
/// Matches reference screenshots and mushaf styling.
abstract class AppColors {
  // Primary brand / mushaf cover green
  static const Color primary = Color(0xFF165A4A);
  static const Color primaryLight = Color(0xFF267D68);
  static const Color primaryDark = Color(0xFF0F3E33);

  // Backgrounds
  static const Color scaffoldLight = Color(0xFFFAF8F2);
  static const Color mushafPaperLight = Color(0xFFFBF9F3);
  static const Color paperBeige = Color(0xFFF1EEE5);
  static const Color softOffWhite = Color(0xFFF7F8FF);

  // Dark Mode Backgrounds
  static const Color scaffoldDark = Color(0xFF1A1C1A);
  static const Color mushafPaperDark = Color(0xFF222222);
  static const Color surfaceDark = Color(0xFF292C31);
  static const Color deepNavyBlack = Color(0xFF11121B);

  // Accents & Neutrals
  static const Color darkWarmBrown = Color(0xFF4A4039);
  static const Color charcoalDarkGray = Color(0xFF333333);
  static const Color mediumGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFFDDDDDD);
  static const Color mutedGreen = Color(0xFF5D9566);
  static const Color tealBlue = Color(0xFF00A2B5);

  // Status & Actions
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}

