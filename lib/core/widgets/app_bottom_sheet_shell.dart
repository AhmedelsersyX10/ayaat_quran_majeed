import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Modal bottom sheet shell with rounded top corners, a drag handle,
/// optional title header, safe area padding, and keyboard avoidance.
class AppBottomSheetShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final bool showDragHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AppBottomSheetShell({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.padding,
    this.backgroundColor,
  });

  /// Helper to show this bottom sheet modal with standardized configuration.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    Color? backgroundColor,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      builder: (ctx) => AppBottomSheetShell(
        title: title,
        trailing: trailing,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: AppRadii.bottomSheetTop,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              if (showDragHandle) ...[
                SizedBox(height: AppSpacing.sm),
                Container(
                  width: AppSizes.dragHandleWidth,
                  height: AppSizes.dragHandleHeight,
                  decoration: BoxDecoration(
                    color: colors.textMuted.withOpacity(0.5),
                    borderRadius: AppRadii.radiusPill,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
              ],

              // Header bar with optional Title and Close button
              if (title != null || showCloseButton || trailing != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      if (showCloseButton)
                        AppIconButton.ghost(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () => Navigator.of(context).maybePop(),
                          iconColor: colors.textSecondary,
                          size: 36,
                        )
                      else
                        const SizedBox(width: 36),
                      Expanded(
                        child: Text(
                          title ?? '',
                          style: AppTypography.titleLarge,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailing != null)
                        trailing!
                      else
                        const SizedBox(width: 36),
                    ],
                  ),
                ),
                Divider(color: colors.divider, height: 1),
              ],

              // Content
              Flexible(
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

