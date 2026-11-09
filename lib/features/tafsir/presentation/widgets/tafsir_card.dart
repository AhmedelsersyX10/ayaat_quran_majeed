import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Distinct rounded card displaying the Tafsir explanation text for an Ayah.
///
/// Pixel-faithful replica of reference 17:
/// - Soft warm beige background fill (`AppColors.ayahHeaderSurface` / #F7EBDD).
/// - Rounded corners (`AppRadii.lg`).
/// - Clear, readable Arabic typography with comfortable line height.
/// - Visually separated from the Quran text above it.
class TafsirCard extends StatelessWidget {
  final String text;
  final bool isRtl;

  const TafsirCard({
    super.key,
    required this.text,
    this.isRtl = true,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.ayahHeaderSurface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Text(
          text,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            height: 1.6,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}
