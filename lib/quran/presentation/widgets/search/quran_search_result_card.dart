import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/quran_search_result.dart';
import '../../../data/repositories/quran_search_repository.dart';

const _metadataService = QuranMetadataService();

class QuranSearchResultCard extends StatelessWidget {
  final QuranSearchResult result;
  final String query;
  final VoidCallback onTap;

  const QuranSearchResultCard({
    Key? key,
    required this.result,
    required this.query,
    required this.onTap,
  }) : super(key: key);

  List<TextSpan> _buildHighlightedText(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedQueryWords = QuranSearchRepository.normalizeArabicText(query)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    if (normalizedQueryWords.isEmpty) {
      return [
        TextSpan(
          text: '${result.originalText} ${_metadataService.getVerseEndSymbol(result.verseNumber)}',
          style: TextStyle(
            fontFamily: 'UthmanicHafs13',
            fontSize: 20.sp,
            color: theme.textTheme.bodyLarge?.color,
            height: 1.8,
          ),
        ),
      ];
    }

    final originalWords = result.originalText.split(' ');
    final spans = <TextSpan>[];

    final defaultStyle = TextStyle(
      fontFamily: 'UthmanicHafs13',
      fontSize: 22.sp,
      color: theme.textTheme.bodyLarge?.color,
      height: 1.8,
    );

    final int colorIndex = getValue("quranPageolorsIndex") ?? 0;
    final highlightStyle = defaultStyle.copyWith(
      color: secondaryColors[colorIndex],
      fontWeight: FontWeight.w700,
      backgroundColor: secondaryColors[colorIndex].withOpacity(0.15),
    );

    for (int i = 0; i < originalWords.length; i++) {
      final originalWord = originalWords[i];
      final normalizedWord = QuranSearchRepository.normalizeArabicText(originalWord);

      bool isMatch = false;
      for (final queryWord in normalizedQueryWords) {
        if (normalizedWord.contains(queryWord)) {
          isMatch = true;
          break;
        }
      }

      spans.add(TextSpan(
        text: '$originalWord ',
        style: isMatch ? highlightStyle : defaultStyle,
      ));
    }

    spans.add(TextSpan(
      text: _metadataService.getVerseEndSymbol(result.verseNumber),
      style: defaultStyle.copyWith(color: secondaryColors[colorIndex]),
    ));

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int colorIndex = getValue("quranPageolorsIndex") ?? 0;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: secondaryColors[colorIndex].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      result.surahName,
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: secondaryColors[colorIndex],
                      ),
                    ),
                  ),
                  Text(
                    'الآية ${result.verseNumber}',
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 12.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Directionality(
                textDirection: TextDirection.rtl,
                child: RichText(
                  text: TextSpan(
                    children: _buildHighlightedText(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
