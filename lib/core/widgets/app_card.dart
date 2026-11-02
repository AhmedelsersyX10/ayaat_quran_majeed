import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

enum AppCardVariant {
  standard,
  primary,
  quote,
}

/// Standard container card matching the reference screenshots.
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  /// Standard warm surface card (#FFFCF7).
  const AppCard.standard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.border,
  }) : variant = AppCardVariant.standard;

  /// Deep green card (#007430) for active day Khatma completion (Screens 26, 31).
  const AppCard.primary({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.border,
  }) : variant = AppCardVariant.primary;

  /// Quoted ayah card with soft pale green background (#D6EED8) (Screen 29).
  const AppCard.quote({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.border,
  }) : variant = AppCardVariant.quote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius = borderRadius ?? AppRadii.radiusMd;
    final effectivePadding = padding ?? EdgeInsets.all(AppSpacing.lg);

    Color bg;
    Border? effectiveBorder = border;

    switch (variant) {
      case AppCardVariant.standard:
        bg = backgroundColor ?? colors.surface;
        effectiveBorder ??= Border.all(color: colors.divider, width: 0.5);
        break;
      case AppCardVariant.primary:
        bg = backgroundColor ?? colors.primary;
        break;
      case AppCardVariant.quote:
        bg = backgroundColor ?? colors.primaryContainer;
        effectiveBorder ??=
            Border.all(color: colors.primaryLight.withOpacity(0.4), width: 1.0);
        break;
    }

    Widget content = Container(
      padding: effectivePadding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: content,
      ),
    );
  }
}
