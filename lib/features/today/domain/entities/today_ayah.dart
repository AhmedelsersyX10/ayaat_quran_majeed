/// Pure Dart entity representing the Ayah of the Day and its accompanying
/// calendar date metadata (both Hijri and Gregorian).
///
/// Contains no Flutter framework dependencies.
class TodayAyah {
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String ayahEndSymbol;
  final int pageNumber;
  final String surahNameArabic;

  /// Eastern Arabic numerals representation of the Hijri day (e.g. `١٩`).
  final String hijriDay;

  /// Arabic name of the Hijri month (e.g. `جمادى الأولى`).
  final String hijriMonthName;

  /// Eastern Arabic numerals representation of the Gregorian day (e.g. `٣٠`).
  final String gregorianDay;

  /// Arabic name of the Gregorian month (e.g. `أكتوبر`).
  final String gregorianMonthName;

  /// The local civil date corresponding to this Ayah.
  final DateTime localDate;

  /// The manual Hijri calendar offset in days (-1, 0, +1) applied to this calculation.
  final int hijriOffset;

  const TodayAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.ayahEndSymbol,
    required this.pageNumber,
    required this.surahNameArabic,
    required this.hijriDay,
    required this.hijriMonthName,
    required this.gregorianDay,
    required this.gregorianMonthName,
    required this.localDate,
    this.hijriOffset = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayAyah &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.ayahText == ayahText &&
        other.ayahEndSymbol == ayahEndSymbol &&
        other.pageNumber == pageNumber &&
        other.surahNameArabic == surahNameArabic &&
        other.hijriDay == hijriDay &&
        other.hijriMonthName == hijriMonthName &&
        other.gregorianDay == gregorianDay &&
        other.gregorianMonthName == gregorianMonthName &&
        other.localDate == localDate &&
        other.hijriOffset == hijriOffset;
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    ayahNumber,
    ayahText,
    ayahEndSymbol,
    pageNumber,
    surahNameArabic,
    hijriDay,
    hijriMonthName,
    gregorianDay,
    gregorianMonthName,
    localDate,
    hijriOffset,
  );

  @override
  String toString() {
    return 'TodayAyah(surah: $surahNumber, ayah: $ayahNumber, page: $pageNumber, date: $localDate, hijriOffset: $hijriOffset)';
  }
}
