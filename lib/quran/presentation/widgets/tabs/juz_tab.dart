import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _metadataService = QuranMetadataService();

class JuzTab extends StatelessWidget {
  final ItemScrollController scrollController;
  final int juzNumberLastRead;
  final Function(int juzNumber, int firstSurah, int firstVerse) onNavigateToJuz;

  const JuzTab({
    Key? key,
    required this.scrollController,
    required this.juzNumberLastRead,
    required this.onNavigateToJuz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: 30,
      itemScrollController: scrollController,
      itemBuilder: (BuildContext context, index) => _buildJuzListItem(context, index),
    );
  }

  Widget _buildJuzListItem(BuildContext context, int index) {
    final juzNumber = index + 1;
    final surahAndVerses = _metadataService.getSurahAndVersesFromJuz(juzNumber);
    final firstSurah = surahAndVerses.keys.first;
    final firstVerse = surahAndVerses.values.first[0];
    final isLastRead = juzNumberLastRead == juzNumber;
    
    final theme = Theme.of(context);

    return Card(
      color: theme.cardTheme.color,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            _metadataService.getSurahNameArabic(firstSurah),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),
          subtitle: Text(
            _metadataService.getVerse(firstSurah, firstVerse),
            style: TextStyle(
              fontFamily: "UthmanicHafs13",
              fontSize: 18.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          onTap: () => onNavigateToJuz(juzNumber, firstSurah, firstVerse),
          leading: _buildJuzNumberCircle(context, juzNumber, isLastRead),
        ),
      ),
    );
  }

  Widget _buildJuzNumberCircle(BuildContext context, int juzNumber, bool isLastRead) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color circleColor;
    if (isLastRead) {
      circleColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFF5E6D3);
    } else {
      circleColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFF5E6D3).withOpacity(.1);
    }
    
    final textColor = isDark ? const Color(0xFFD2B48C) : const Color.fromARGB(228, 0, 0, 0);

    return Container(
      width: 33.sp,
      height: 33.sp,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: Center(
        child: Text(
          juzNumber.toString(),
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
