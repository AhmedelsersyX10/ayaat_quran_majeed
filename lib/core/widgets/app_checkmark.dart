import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Circular green checkmark badge used in downloaded surahs (Screen 36)
/// and selected ayah picker rows (Screens 38, 39).
class AppCheckmark extends StatelessWidget {
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppCheckmark({
    super.key,
    this.size,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize = size ?? AppSizes.checkmarkSize;
    final bg = backgroundColor ?? colors.primary;
    final fg = iconColor ?? colors.textOnPrimary;

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        size: effectiveSize * 0.7,
        color: fg,
      ),
    );
  }
}

