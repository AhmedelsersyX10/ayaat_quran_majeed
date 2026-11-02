import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  text,
}

/// Standard button primitive used across the entire Ayaat app.
/// Matches the reference design in screens 10, 23, 26, 29, 31.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  /// Full-width or standard CTA button (e.g. "بدء ختمة جديدة", "حفظ").
  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.primary;

  /// Secondary or outlined button (e.g. "عرض جميع الأوراد", "إلغاء").
  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  /// Destructive action button (e.g. "حذف الختمة").
  const AppButton.destructive({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.destructive;

  /// Plain text button with no container (e.g. dialog actions).
  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveHeight = height ?? AppSizes.buttonHeightLg;
    final effectiveRadius = borderRadius ?? AppRadii.radiusMd;
    final canTap = isEnabled && !isLoading && onPressed != null;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primary;
        foregroundColor = colors.textOnPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.surface;
        foregroundColor = colors.textPrimary;
        borderSide = BorderSide(color: colors.border, width: 1.0);
        break;
      case AppButtonVariant.destructive:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.destructive;
        borderSide =
            BorderSide(color: colors.destructive.withOpacity(0.5), width: 1.0);
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.primary;
        break;
    }

    if (!canTap && variant == AppButtonVariant.primary) {
      backgroundColor = colors.primary.withOpacity(0.4);
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              text,
              style: AppTypography.labelLarge.copyWith(
                color:
                    canTap ? foregroundColor : foregroundColor.withOpacity(0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: Material(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: canTap ? onPressed : null,
          borderRadius: effectiveRadius,
          child: Container(
            padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              border: borderSide != BorderSide.none
                  ? Border.fromBorderSide(borderSide)
                  : null,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
