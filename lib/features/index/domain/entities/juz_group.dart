import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';

/// Domain entity representing a Juz section grouping Surahs within the Quran Index.
/// Pure Dart — no Flutter framework dependencies.
class JuzGroup {
  /// Juz number (1 to 30).
  final int juzNumber;

  /// Arabic ordinal name for this Juz (e.g. "الأول", "الثاني", ..., "الثلاثون").
  final String nameArabic;

  /// The first Mushaf page number belonging to this Juz (1 to 604).
  final int startPage;

  /// The list of Surahs that start within this Juz.
  ///
  /// Can be empty for boundary Juz where a previous Surah spans the entire Juz
  /// (e.g. Juz 2 spanned by Al-Baqarah, Juz 5 spanned by An-Nisa).
  final List<SurahIndexItem> surahs;

  const JuzGroup({
    required this.juzNumber,
    required this.nameArabic,
    required this.startPage,
    required this.surahs,
  });

  /// Whether any Surah starts in this Juz.
  bool get hasSurahs => surahs.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JuzGroup) return false;
    if (other.juzNumber != juzNumber ||
        other.nameArabic != nameArabic ||
        other.startPage != startPage ||
        other.surahs.length != surahs.length) {
      return false;
    }
    for (int i = 0; i < surahs.length; i++) {
      if (surahs[i] != other.surahs[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        juzNumber,
        nameArabic,
        startPage,
        Object.hashAll(surahs),
      );

  @override
  String toString() =>
      'JuzGroup($juzNumber: $nameArabic, page: $startPage, surahs: ${surahs.length})';
}
