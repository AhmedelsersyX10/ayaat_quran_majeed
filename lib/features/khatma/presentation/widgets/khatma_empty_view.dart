import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Khatma Empty State view conforming strictly to Reference Screenshot 10.
///
/// Features:
/// - Unadorned top AppBar with right-aligned "الختمة" (Title) in displayLarge bold.
/// - Centered guidance paragraph explaining daily wird and reading tracking.
/// - Primary green CTA button: "بدء ختمة جديدة".
class KhatmaEmptyView extends StatelessWidget {
  final VoidCallback onStartKhatma;

  const KhatmaEmptyView({
    super.key,
    required this.onStartKhatma,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.tr(AppStrings.khatmaTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 320.w),
                  child: Text(
                    AppStrings.tr(AppStrings.khatmaGuidanceDesc),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 240.w,
                  child: AppButton.primary(
                    text: AppStrings.tr(AppStrings.startKhatmaBtn),
                    onPressed: onStartKhatma,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
