import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders the Mushaf page top header:
/// - Right side (RTL start): Juz ordinal label (e.g. "الجزء الأول")
/// - Left side (RTL end): Surah name (e.g. "الفاتحة", "البقرة")
///
/// Fully derived from [QuranMetadataService] without any hardcoded per-page content.
class MushafPageHeader extends StatelessWidget {
  final int pageNumber;
  final QuranMetadataService metadataService;

  const MushafPageHeader({
    super.key,
    required this.pageNumber,
    this.metadataService = const QuranMetadataService(),
  });

  @override
  Widget build(BuildContext context) {
    if (pageNumber < 1 || pageNumber > 604) {
      return const SizedBox.shrink();
    }

    final int juzNumber = metadataService.getJuzNumberForPage(pageNumber);
    final String juzName = metadataService.getJuzNameArabic(juzNumber);
    final String surahName = metadataService.getSurahNameArabicForPage(
      pageNumber,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'الجزء $juzName',
                style: AppTypography.mushafPageHeader,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                surahName,
                style: AppTypography.mushafPageHeader,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
