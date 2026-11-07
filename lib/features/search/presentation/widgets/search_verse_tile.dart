import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/verse_search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Verse search result item matching screenshot 15.
class SearchVerseTile extends StatelessWidget {
  final VerseSearchResult result;
  final VoidCallback onTap;

  const SearchVerseTile({
    Key? key,
    required this.result,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ayahLabel = formatAyahLabel(result.surahName, result.verseNumber);
    final pageNumberStr = toArabicDigits(result.pageNumber);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with Surah:Ayah on right and Page on left (in RTL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  ayahLabel,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  pageNumberStr,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Quranic Hafs text
            Text(
              result.originalText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'UthmanicHafs13',
                fontSize: 20.sp,
                height: 1.8,
                color: AppColors.textTafsir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
