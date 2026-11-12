import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Individual Starred Ayah row item inside a Surah Card.
/// Pixel-faithful matching reference screenshot 28.
class StarredAyahItemView extends StatelessWidget {
  final StarredAyahItem item;
  final VoidCallback onTap;

  const StarredAyahItemView({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final subtitle = formatPageAyahLabel(
      surahName: item.surahName,
      ayahNumber: item.verseNumber,
      pageNumber: item.pageNumber,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Ayah Uthmanic Script Text
            Text(
              item.ayahText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.quranText.copyWith(
                fontSize: 19.sp,
                height: 1.8,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            // 2. Subtitle: e.g. "البقرة: ٢ - الصفحة ٢"
            Text(
              subtitle,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

