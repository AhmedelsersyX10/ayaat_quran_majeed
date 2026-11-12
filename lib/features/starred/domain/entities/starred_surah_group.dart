import 'starred_ayah_item.dart';

/// Domain entity representing a collection of starred verses belonging to a specific Surah.
/// Matches reference screenshot 28 where verses are grouped under their Surah header.
class StarredSurahGroup {
  final int surahNumber;
  final String surahName;
  final List<StarredAyahItem> items;

  const StarredSurahGroup({
    required this.surahNumber,
    required this.surahName,
    required this.items,
  });

  /// Groups a flat list of [StarredAyahItem]s deterministically:
  /// 1. Grouped by [surahNumber].
  /// 2. Surahs sorted in Quranic order (surahNumber ascending: 1 -> 114).
  /// 3. Verses within each surah sorted in Quranic order (verseNumber ascending: 1 -> N).
  static List<StarredSurahGroup> groupBySurah(List<StarredAyahItem> items) {
    if (items.isEmpty) return const [];

    final Map<int, List<StarredAyahItem>> map = {};
    for (final item in items) {
      map.putIfAbsent(item.surahNumber, () => <StarredAyahItem>[]).add(item);
    }

    final sortedSurahNumbers = map.keys.toList()..sort();
    final List<StarredSurahGroup> result = [];

    for (final surahNumber in sortedSurahNumbers) {
      final surahItems = map[surahNumber]!;
      surahItems.sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
      final surahName = surahItems.first.surahName;
      result.add(
        StarredSurahGroup(
          surahNumber: surahNumber,
          surahName: surahName,
          items: List.unmodifiable(surahItems),
        ),
      );
    }

    return List.unmodifiable(result);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StarredSurahGroup) return false;
    if (surahNumber != other.surahNumber || surahName != other.surahName) {
      return false;
    }
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        surahNumber,
        surahName,
        Object.hashAll(items),
      );

  @override
  String toString() =>
      'StarredSurahGroup(surah: $surahName (#$surahNumber), count: ${items.length})';
}

