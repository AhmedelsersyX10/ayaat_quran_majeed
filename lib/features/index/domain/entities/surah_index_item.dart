/// Domain entity representing a Surah within the Quran Index.
/// Pure Dart — no Flutter framework dependencies.
class SurahIndexItem {
  /// Canonical Surah number (1 to 114).
  final int number;

  /// Canonical Arabic name of the Surah (e.g. "الفاتحة", "البقرة").
  final String nameArabic;

  /// Starting Mushaf page number (1 to 604).
  final int pageNumber;

  /// Total number of verses in this Surah.
  final int verseCount;

  /// Whether the Surah was revealed in Makkah (`true`) or Madinah (`false`).
  final bool isMakki;

  /// The Juz number (1 to 30) where the first verse of this Surah resides.
  final int startJuz;

  const SurahIndexItem({
    required this.number,
    required this.nameArabic,
    required this.pageNumber,
    required this.verseCount,
    required this.isMakki,
    required this.startJuz,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurahIndexItem &&
        other.number == number &&
        other.nameArabic == nameArabic &&
        other.pageNumber == pageNumber &&
        other.verseCount == verseCount &&
        other.isMakki == isMakki &&
        other.startJuz == startJuz;
  }

  @override
  int get hashCode => Object.hash(
        number,
        nameArabic,
        pageNumber,
        verseCount,
        isMakki,
        startJuz,
      );

  @override
  String toString() =>
      'SurahIndexItem($number: $nameArabic, page: $pageNumber, ayahs: $verseCount, juz: $startJuz, makki: $isMakki)';
}
