import 'package:flutter/material.dart';

/// Blend two colors together using linear interpolation.
Color blendColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t) ?? a;
}

/// Create an adaptive tone for mushaf decorative elements based on luminance.
Color mushafDividerTone(Color color) {
  final luma = color.computeLuminance();
  final target = luma < 0.45 ? const Color(0xFFF4E6C8) : const Color(0xFF3B2A16);
  final t = luma < 0.45 ? 0.65 : 0.25;
  return blendColor(color, target, t);
}
