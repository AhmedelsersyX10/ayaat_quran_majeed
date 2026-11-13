import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Universal list row primitive used across Surahs, Quarters, Bookmarks,
/// Wirds, Notes, and Settings screens.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final bool isSelected;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.contentPadding,
    this.backgroundColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final padding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );

    final rowContent = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: AppSpacing.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: AppTypography.titleMedium.copyWith(
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    DefaultTextStyle(
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );

    Widget item = backgroundColor != null || isSelected
        ? ColoredBox(
            color: isSelected
                ? colors.primaryContainer.withOpacity(0.3)
                : backgroundColor!,
            child: rowContent,
          )
        : rowContent;

    if (onTap != null) {
      item = InkWell(onTap: onTap, child: item);
    }

    item = Semantics(button: onTap != null, selected: isSelected, child: item);

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          item,
          Divider(
            color: colors.divider,
            height: 0.5,
            thickness: 0.5,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
        ],
      );
    }

    return item;
  }
}
