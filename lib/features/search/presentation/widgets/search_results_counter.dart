import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Subheader counter displaying "الآيات (٤٥)" matching screenshot 15.
class SearchResultsCounter extends StatelessWidget {
  final int count;

  const SearchResultsCounter({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countStr = toArabicDigits(count);
    final text = '${AppStrings.tr(AppStrings.searchVersesHeader)} ($countStr)';

    return Container(
      width: double.infinity,
      color: AppColors.readerSurface.withOpacity(0.4),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
