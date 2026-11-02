import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Modal dialog shell matching screens 23 (time picker) and 29 (note editor).
class AppDialogShell extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool showCloseButton;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;

  const AppDialogShell({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.showCloseButton = true,
    this.contentPadding,
    this.maxWidth,
  });

  /// Helper to show this standardized dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    double? maxWidth,
  }) {
    final colors = context.colors;
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: colors.scrim,
      builder: (ctx) => AppDialogShell(
        title: title,
        actions: actions,
        showCloseButton: showCloseButton,
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.scaffoldBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.radiusLg,
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header with Close button
            if (title != null || showCloseButton) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    if (showCloseButton)
                      AppIconButton.ghost(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () => Navigator.of(context).maybePop(),
                        iconColor: colors.textSecondary,
                        size: 32,
                      )
                    else
                      const SizedBox(width: 32),
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: AppTypography.titleLarge,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              Divider(color: colors.divider, height: 1),
            ],

            // Dialog Content
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ?? EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
            ),

            // Dialog Actions Footer
            if (actions != null && actions!.isNotEmpty) ...[
              Divider(color: colors.divider, height: 1),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map(
                        (action) => Padding(
                          padding: EdgeInsets.only(right: AppSpacing.sm),
                          child: action,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

