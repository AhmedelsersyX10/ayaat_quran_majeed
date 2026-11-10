import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

import '../entities/khatma_29_day_table.dart';
import '../entities/khatma_program.dart';
import '../entities/khatma_wird.dart';

/// Helper representation for a raw wird definition before metadata enrichment.
class _RawWirdDefinition {
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final String? customTitle;
  final String rangeText;

  const _RawWirdDefinition({
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    this.customTitle,
    required this.rangeText,
  });
}

/// Service calculating deterministic daily Quran portions (Wirds) for any Khatma program.
///
/// Enriches range boundaries with live page numbers, Surah names, and verses
/// directly from [QuranMetadataService] without duplicating data.
class KhatmaWirdCalculator {
  final QuranMetadataService _metadataService;

  const KhatmaWirdCalculator({
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _metadataService = metadataService;

  /// Calculates the complete list of [KhatmaWird] for [program] starting at [startDate].
  ///
  /// If [startWirdNumber] > 1, preceding wirds are marked as completed,
  /// and [startWirdNumber] is scheduled for [startDate].
  List<KhatmaWird> calculateWirds({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
  }) {
    final definitions = _getDefinitionsForProgram(program);
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    final clampedStartWird = startWirdNumber.clamp(1, definitions.length);

    final result = <KhatmaWird>[];

    for (int i = 0; i < definitions.length; i++) {
      final dayNumber = i + 1;
      final def = definitions[i];
      final isPreCompleted = dayNumber < clampedStartWird;

      // Scheduled date offset: Day clampedStartWird falls on normalizedStartDate
      final dayOffset = dayNumber - clampedStartWird;
      final scheduledDate = DateTime(
        normalizedStartDate.year,
        normalizedStartDate.month,
        normalizedStartDate.day + dayOffset,
      );

      final startSurahName = _metadataService.getSurahNameArabic(def.startSurah);
      final endSurahName = _metadataService.getSurahNameArabic(def.endSurah);
      final startPage = _metadataService.getPageNumber(def.startSurah, def.startAyah);
      final endPage = _metadataService.getPageNumber(def.endSurah, def.endAyah);
      final firstVerse = _metadataService.getVerse(def.startSurah, def.startAyah);
      final lastVerse = _metadataService.getVerse(def.endSurah, def.endAyah);

      result.add(
        KhatmaWird(
          dayNumber: dayNumber,
          scheduledDate: scheduledDate,
          startSurahNumber: def.startSurah,
          startAyahNumber: def.startAyah,
          endSurahNumber: def.endSurah,
          endAyahNumber: def.endAyah,
          startPageNumber: startPage,
          endPageNumber: endPage,
          startSurahName: startSurahName,
          endSurahName: endSurahName,
          firstVerseText: firstVerse,
          lastVerseText: lastVerse,
          customTitle: def.customTitle,
          rangeText: def.rangeText,
          isCompleted: isPreCompleted,
          completedAt: isPreCompleted ? normalizedStartDate : null,
        ),
      );
    }

    return result;
  }

  /// Returns true if [surahNumber] and [ayahNumber] denote a valid verse in the Quran.
  bool isValidAyahPosition(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return false;
    final verseCount = _metadataService.getVerseCount(surahNumber);
    if (ayahNumber < 1 || ayahNumber > verseCount) return false;
    return true;
  }

  /// Returns true if [pageNumber] is a valid Madani Mushaf page (1..604).
  bool isValidPagePosition(int pageNumber) {
    return pageNumber >= 1 && pageNumber <= 604;
  }

  /// Finds the 1-based wird number in [program] that contains [surahNumber] and [ayahNumber].
  ///
  /// Throws [ArgumentError] if the verse position is invalid.
  int findWirdNumberForAyah({
    required KhatmaProgram program,
    required int surahNumber,
    required int ayahNumber,
  }) {
    if (!isValidAyahPosition(surahNumber, ayahNumber)) {
      throw ArgumentError(
        'Invalid Quran verse position: surah $surahNumber, ayah $ayahNumber',
      );
    }

    final definitions = _getDefinitionsForProgram(program);
    for (int i = 0; i < definitions.length; i++) {
      final def = definitions[i];
      final afterStart = _compareVerses(
            surahNumber,
            ayahNumber,
            def.startSurah,
            def.startAyah,
          ) >=
          0;
      final beforeEnd = _compareVerses(
            surahNumber,
            ayahNumber,
            def.endSurah,
            def.endAyah,
          ) <=
          0;
      if (afterStart && beforeEnd) {
        return i + 1;
      }
    }

    return 1;
  }

  /// Finds the 1-based wird number in [program] that contains [pageNumber] (1..604).
  ///
  /// Throws [ArgumentError] if [pageNumber] is not between 1 and 604.
  int findWirdNumberForPage({
    required KhatmaProgram program,
    required int pageNumber,
  }) {
    if (!isValidPagePosition(pageNumber)) {
      throw ArgumentError('Invalid Mushaf page: $pageNumber');
    }

    final pageSegments = _metadataService.getPageData(pageNumber);
    if (pageSegments.isNotEmpty) {
      final first = pageSegments.first;
      final surah = (first['surah'] as num).toInt();
      final startAyah = (first['start'] as num).toInt();
      return findWirdNumberForAyah(
        program: program,
        surahNumber: surah,
        ayahNumber: startAyah,
      );
    }
    return 1;
  }

  static int _compareVerses(int s1, int a1, int s2, int a2) {
    if (s1 != s2) return s1.compareTo(s2);
    return a1.compareTo(a2);
  }

  /// Selects the raw wird definitions based on the program id.
  List<_RawWirdDefinition> _getDefinitionsForProgram(KhatmaProgram program) {
    if (program.id == 'meaning_29' || program.totalDays == 29) {
      return _meaning29Definitions;
    }
    if (program.id == 'parts_30' || program.totalDays == 30) {
      return _generateJuzDefinitions(30);
    }
    if (program.id == 'meaning_7' || program.totalDays == 7) {
      return _meaning7Definitions;
    }
    if (program.category == KhatmaProgramCategory.partsAndQuarters ||
        program.id.startsWith('quarters_') ||
        program.id.startsWith('parts_')) {
      return _generateQuartersBasedDefinitions(program.totalDays);
    }
    // Fallback: 29-day table
    return _meaning29Definitions;
  }

  /// Canonical 29-day table sourced from [Khatma29DayTable].
  static List<_RawWirdDefinition> get _meaning29Definitions => Khatma29DayTable.days
      .map(
        (e) => _RawWirdDefinition(
          startSurah: e.startSurah,
          startAyah: e.startAyah,
          endSurah: e.endSurah,
          endAyah: e.endAyah,
          customTitle: e.customTitle,
          rangeText: e.rangeText,
        ),
      )
      .toList(growable: false);

  /// Traditional 7-day Manzil division.
  static final List<_RawWirdDefinition> _meaning7Definitions = [
    const _RawWirdDefinition(
      startSurah: 1,
      startAyah: 1,
      endSurah: 4,
      endAyah: 176,
      rangeText: 'من الفاتحة إلى نهاية النساء',
    ),
    const _RawWirdDefinition(
      startSurah: 5,
      startAyah: 1,
      endSurah: 9,
      endAyah: 129,
      rangeText: 'من المائدة إلى نهاية التوبة',
    ),
    const _RawWirdDefinition(
      startSurah: 10,
      startAyah: 1,
      endSurah: 16,
      endAyah: 128,
      rangeText: 'من يونس إلى نهاية النحل',
    ),
    const _RawWirdDefinition(
      startSurah: 17,
      startAyah: 1,
      endSurah: 25,
      endAyah: 77,
      rangeText: 'من الإسراء إلى نهاية الفرقان',
    ),
    const _RawWirdDefinition(
      startSurah: 26,
      startAyah: 1,
      endSurah: 36,
      endAyah: 83,
      rangeText: 'من الشعراء إلى نهاية يس',
    ),
    const _RawWirdDefinition(
      startSurah: 37,
      startAyah: 1,
      endSurah: 49,
      endAyah: 18,
      rangeText: 'من الصافات إلى نهاية الحجرات',
    ),
    const _RawWirdDefinition(
      startSurah: 50,
      startAyah: 1,
      endSurah: 114,
      endAyah: 6,
      rangeText: 'من ق إلى نهاية الناس',
    ),
  ];

  /// Generates Juz-based definitions for 30-day programs.
  List<_RawWirdDefinition> _generateJuzDefinitions(int totalDays) {
    final list = <_RawWirdDefinition>[];
    for (int juz = 1; juz <= 30; juz++) {
      final versesMap = _metadataService.getSurahAndVersesFromJuz(juz);
      final firstSurah = versesMap.keys.first;
      final firstAyah = versesMap[firstSurah]!.first;
      final lastSurah = versesMap.keys.last;
      final lastAyah = versesMap[lastSurah]!.last;

      final juzOrdinal = _metadataService.getJuzNameArabic(juz);
      list.add(
        _RawWirdDefinition(
          startSurah: firstSurah,
          startAyah: firstAyah,
          endSurah: lastSurah,
          endAyah: lastAyah,
          customTitle: 'الجزء $juzOrdinal',
          rangeText: 'الجزء $juzOrdinal',
        ),
      );
    }
    return list;
  }

  /// Generates quarter-based definitions for programs dividing the 240 quarters.
  List<_RawWirdDefinition> _generateQuartersBasedDefinitions(int totalDays) {
    final quarters = _metadataService.quartersRaw;
    final totalQuarters = quarters.length; // 240
    final list = <_RawWirdDefinition>[];

    final step = (totalQuarters / totalDays).ceil();

    for (int day = 0; day < totalDays; day++) {
      final startQuarterIdx = day * step;
      if (startQuarterIdx >= totalQuarters) break;

      final endQuarterIdx = ((day + 1) * step).clamp(0, totalQuarters);

      final startEntry = quarters[startQuarterIdx];
      final startSurah = startEntry['surah'] as int;
      final startAyah = startEntry['ayah'] as int;

      int endSurah;
      int endAyah;

      if (endQuarterIdx >= totalQuarters) {
        endSurah = 114;
        endAyah = 6;
      } else {
        // Find preceding verse of the next quarter
        final nextQuarterEntry = quarters[endQuarterIdx];
        final nextSurah = nextQuarterEntry['surah'] as int;
        final nextAyah = nextQuarterEntry['ayah'] as int;

        if (nextAyah > 1) {
          endSurah = nextSurah;
          endAyah = nextAyah - 1;
        } else {
          endSurah = nextSurah - 1;
          endAyah = _metadataService.getVerseCount(endSurah);
        }
      }

      final startSurahName = _metadataService.getSurahNameArabic(startSurah);
      final endSurahName = _metadataService.getSurahNameArabic(endSurah);

      final range = (startSurah == endSurah)
          ? '$startSurahName: ${toArabicDigits(startAyah)} إلى ${toArabicDigits(endAyah)}'
          : 'من $startSurahName: ${toArabicDigits(startAyah)} إلى $endSurahName: ${toArabicDigits(endAyah)}';

      list.add(
        _RawWirdDefinition(
          startSurah: startSurah,
          startAyah: startAyah,
          endSurah: endSurah,
          endAyah: endAyah,
          rangeText: range,
        ),
      );
    }

    return list;
  }
}

