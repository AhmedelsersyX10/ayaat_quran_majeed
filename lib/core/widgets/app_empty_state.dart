import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Standard empty state presentation matching screens 10, 12, 13, 21.
class AppEmptyState extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final EdgeInsetsGeometry? padding;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.buttonText,
    this.onButtonPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: padding ?? EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(height: AppSpacing.xl),
            ],
            Text(
              title,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: AppSpacing.xxl),
              AppButton.primary(
                text: buttonText!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

