import 'package:flutter/material.dart';

/// Represents visual styles and colors for the exported Ayah image card.
class ShareCardTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final Color borderColor;
  final Color headerSurfaceColor;
  final Color badgeTextColor;
  final bool isDark;

  const ShareCardTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.borderColor,
    required this.headerSurfaceColor,
    required this.badgeTextColor,
    this.isDark = false,
  });

  /// Default theme: warm cream / mushaf parchment.
  static const ShareCardTheme creamParchment = ShareCardTheme(
    id: 'cream_parchment',
    name: 'المصحف الورقي',
    backgroundColor: Color(0xFFFFFDF8),
    textColor: Color(0xFF2D2A26),
    accentColor: Color(0xFF007330),
    borderColor: Color(0xFFE8DECB),
    headerSurfaceColor: Color(0xFFF7EBDD),
    badgeTextColor: Color(0xFF5A442E),
    isDark: false,
  );

  /// Pure modern white with brand green accents.
  static const ShareCardTheme pureWhite = ShareCardTheme(
    id: 'pure_white',
    name: 'أبيض ناصع',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    accentColor: Color(0xFF007330),
    borderColor: Color(0xFFE0E0E0),
    headerSurfaceColor: Color(0xFFF1F8E9),
    badgeTextColor: Color(0xFF1B5E20),
    isDark: false,
  );

  /// Warm brown with golden camel accents.
  static const ShareCardTheme warmBrown = ShareCardTheme(
    id: 'warm_brown',
    name: 'بني دافئ',
    backgroundColor: Color(0xFFF8F3EA),
    textColor: Color(0xFF3E2723),
    accentColor: Color(0xFF8D6E63),
    borderColor: Color(0xFFD7CCC8),
    headerSurfaceColor: Color(0xFFEFEBE9),
    badgeTextColor: Color(0xFF4E342E),
    isDark: false,
  );

  /// Soft emerald green theme.
  static const ShareCardTheme emeraldGreen = ShareCardTheme(
    id: 'emerald_green',
    name: 'زمردي',
    backgroundColor: Color(0xFFF0F7F2),
    textColor: Color(0xFF0F381E),
    accentColor: Color(0xFF007330),
    borderColor: Color(0xFFC2E0CC),
    headerSurfaceColor: Color(0xFFD6EED8),
    badgeTextColor: Color(0xFF005C27),
    isDark: false,
  );

  /// Elegant dark / night theme.
  static const ShareCardTheme royalDark = ShareCardTheme(
    id: 'royal_dark',
    name: 'ليلي داكن',
    backgroundColor: Color(0xFF1F2220),
    textColor: Color(0xFFF5F5F5),
    accentColor: Color(0xFF81C784),
    borderColor: Color(0xFF333833),
    headerSurfaceColor: Color(0xFF293029),
    badgeTextColor: Color(0xFFA5D6A7),
    isDark: true,
  );

  static const ShareCardTheme defaultTheme = creamParchment;

  static const List<ShareCardTheme> predefinedThemes = [
    creamParchment,
    pureWhite,
    warmBrown,
    emeraldGreen,
    royalDark,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareCardTheme && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
