import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Reusable error presentation with retry action.
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? icon;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  Iconsax.info_circle,
                  size: 48,
                  color: colors.destructive,
                ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              AppButton.secondary(
                text: retryText ?? AppStrings.tr(AppStrings.retry),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable centered loading indicator.
class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

