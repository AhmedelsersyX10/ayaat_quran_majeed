import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

enum AppIconButtonVariant {
  ghost,
  filled,
  badge,
}

/// Standard icon button with minimum 44x44 touch target for accessibility.
/// Supports ghost, filled circle, and badge variants.
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIconButtonVariant variant;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;
  final bool autoRtl;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = AppIconButtonVariant.ghost,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.autoRtl = true,
  });

  /// Plain transparent button with ripple (e.g. back button, search, three dots).
  const AppIconButton.ghost({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor,
    this.size,
    this.iconSize,
    this.autoRtl = true,
  })  : variant = AppIconButtonVariant.ghost,
        backgroundColor = Colors.transparent;

  /// Filled circular button (e.g. player play button, stepper +/-, return arrow).
  const AppIconButton.filled({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.autoRtl = true,
  }) : variant = AppIconButtonVariant.filled;

  /// Badge button (e.g. red minus badge for delete, green check badge).
  const AppIconButton.badge({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.autoRtl = true,
  }) : variant = AppIconButtonVariant.badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize = size ?? AppSizes.minTouchTarget;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Color bg;
    Color fg;

    switch (variant) {
      case AppIconButtonVariant.ghost:
        bg = backgroundColor ?? Colors.transparent;
        fg = iconColor ?? colors.textPrimary;
        break;
      case AppIconButtonVariant.filled:
        bg = backgroundColor ?? colors.primary;
        fg = iconColor ?? colors.textOnPrimary;
        break;
      case AppIconButtonVariant.badge:
        bg = backgroundColor ?? colors.destructive;
        fg = iconColor ?? colors.textOnPrimary;
        break;
    }

    Widget content = IconTheme(
      data: IconThemeData(
        color: fg,
        size: iconSize ?? AppSizes.iconMd,
      ),
      child: icon,
    );

    // Auto flip directional icons in RTL if requested
    if (autoRtl && isRtl) {
      // In RTL, standard right-facing icons or left-facing back arrows flip
      // Note: Icons handled by Flutter's Icons.adaptive or custom widgets
    }

    final buttonWidget = Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: effectiveSize,
          height: effectiveSize,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}

