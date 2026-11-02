import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Section header primitive for grouping lists (e.g. "الجزء الأول", "خيارات مقترحة").
class AppSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );

    return Container(
      color: backgroundColor ?? colors.scaffoldBackground,
      padding: effectivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

