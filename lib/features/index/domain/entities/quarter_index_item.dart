/// Domain entity representing a canonical Quarter (Rub' el Hizb) in the Quran Index.
///
/// Follows Clean Architecture domain entity rules — pure Dart, no Flutter dependencies.
class QuarterIndexItem {
  /// Canonical quarter sequence number (1 to 240).
  final int quarterNumber;

  /// The Hizb number containing this quarter (1 to 60).
  final int hizbNumber;

  /// Quarter position within the Hizb (1 to 4):
  /// - 1: Start of Hizb
  /// - 2: First quarter (1/4)
  /// - 3: Half Hizb (1/2)
  /// - 4: Three quarters (3/4)
  final int quarterInHizb;

  /// Surah number where this quarter starts (1 to 114).
  final int surahNumber;

  /// Surah Arabic name (e.g. "الفاتحة", "البقرة").
  final String surahNameArabic;

  /// Ayah number where this quarter begins.
  final int ayahNumber;

  /// Mushaf page number where this quarter begins (1 to 604).
  final int pageNumber;

  /// Opening verse snippet formatted in Quranic Uthmanic script.
  final String ayahText;

  const QuarterIndexItem({
    required this.quarterNumber,
    required this.hizbNumber,
    required this.quarterInHizb,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.pageNumber,
    required this.ayahText,
  });

  QuarterIndexItem copyWith({
    int? quarterNumber,
    int? hizbNumber,
    int? quarterInHizb,
    int? surahNumber,
    String? surahNameArabic,
    int? ayahNumber,
    int? pageNumber,
    String? ayahText,
  }) {
    return QuarterIndexItem(
      quarterNumber: quarterNumber ?? this.quarterNumber,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      quarterInHizb: quarterInHizb ?? this.quarterInHizb,
      surahNumber: surahNumber ?? this.surahNumber,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      ayahText: ayahText ?? this.ayahText,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuarterIndexItem &&
          runtimeType == other.runtimeType &&
          quarterNumber == other.quarterNumber &&
          hizbNumber == other.hizbNumber &&
          quarterInHizb == other.quarterInHizb &&
          surahNumber == other.surahNumber &&
          surahNameArabic == other.surahNameArabic &&
          ayahNumber == other.ayahNumber &&
          pageNumber == other.pageNumber &&
          ayahText == other.ayahText;

  @override
  int get hashCode => Object.hash(
        quarterNumber,
        hizbNumber,
        quarterInHizb,
        surahNumber,
        surahNameArabic,
        ayahNumber,
        pageNumber,
        ayahText,
      );

  @override
  String toString() =>
      'QuarterIndexItem(quarter: $quarterNumber, hizb: $hizbNumber, '
      'part: $quarterInHizb, surah: $surahNumber ($surahNameArabic), '
      'ayah: $ayahNumber, page: $pageNumber)';
}
