import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/quarter_index_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Callback invoked when a Quarter row is tapped.
/// Passes [pageNumber] (1-604) and [quarterNumber] (1-240).
typedef QuarterSelectedCallback = void Function(
    int pageNumber, int quarterNumber);

/// Displays the 240 canonical Quran Quarters (Rub' el Hizb) with progress indicators
/// matching Reference Screenshot 04.
///
/// Fully responsive via `flutter_screenutil`, RTL-aligned, and supports jumping
/// directly to the reader by passing primitive page numbers.
class QuartersListView extends StatelessWidget {
  /// The 240 canonical quarters.
  final List<QuarterIndexItem> quarters;

  /// The active/current reading Quarter sequence number (1 to 240) highlighted with primary green.
  final int currentReadingQuarter;

  /// Optional callback invoked when a Quarter row is selected.
  final QuarterSelectedCallback? onQuarterSelected;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Optional list padding.
  final EdgeInsetsGeometry? padding;

  const QuartersListView({
    super.key,
    required this.quarters,
    this.currentReadingQuarter = 1,
    this.onQuarterSelected,
    this.controller,
    this.padding,
  });

  static const Color _inactiveHizbCircleColor = Color(0xFFDDD1C5);
  static const Color _inactiveQuarterArcColor = Color(0xFFBAA797);
  static const Color _quarterTrackColor = Color(0xFFEFECE6);

  HizbQuarterType _quarterTypeFor(int quarterInHizb) {
    switch (quarterInHizb) {
      case 2:
        return HizbQuarterType.firstQuarter;
      case 3:
        return HizbQuarterType.half;
      case 4:
        return HizbQuarterType.threeQuarters;
      default:
        return HizbQuarterType.full;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding ?? EdgeInsets.symmetric(vertical: 8.h),
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final quarter = quarters[index];
        return _buildQuarterRow(context, quarter);
      },
    );
  }

  Widget _buildQuarterRow(BuildContext context, QuarterIndexItem quarter) {
    final colors = context.colors;
    final isCurrent = quarter.quarterNumber == currentReadingQuarter;
    final isHizbStart = quarter.quarterInHizb == 1;

    final subtitleText =
        '${quarter.surahNameArabic}: ${toArabicDigits(quarter.ayahNumber)} - '
        '${AppStrings.tr(AppStrings.alPage)} ${toArabicDigits(quarter.pageNumber)}';

    return InkWell(
      onTap: onQuarterSelected != null
          ? () => onQuarterSelected!(quarter.pageNumber, quarter.quarterNumber)
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Row(
          children: [
            // Circular Progress Indicator (38.w fixed size across all quarters)
            if (isHizbStart)
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? colors.primary : _inactiveHizbCircleColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  toArabicDigits(quarter.hizbNumber),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCurrent
                        ? colors.textOnPrimary
                        : colors.textPrimary,
                  ),
                ),
              )
            else
              HizbQuarterIndicator(
                type: _quarterTypeFor(quarter.quarterInHizb),
                size: 38.w,
                activeColor:
                    isCurrent ? colors.primary : _inactiveQuarterArcColor,
                trackColor: _quarterTrackColor,
              ),

            SizedBox(width: 14.w),

            // Quarter Verse snippet and Subtitle Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quarter.ayahText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.quranText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitleText,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
