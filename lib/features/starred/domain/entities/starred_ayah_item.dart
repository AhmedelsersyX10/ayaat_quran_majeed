/// Domain entity representing a starred Quran verse.
/// Pure Dart — no Flutter framework dependencies.
class StarredAyahItem {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final String ayahText;
  final String surahName;
  final DateTime? createdAt;

  const StarredAyahItem({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.ayahText,
    required this.surahName,
    this.createdAt,
  });

  /// Canonical identifier key for the verse (e.g. "2:255").
  String get key => '$surahNumber:$verseNumber';

  StarredAyahItem copyWith({
    int? surahNumber,
    int? verseNumber,
    int? pageNumber,
    String? ayahText,
    String? surahName,
    DateTime? createdAt,
  }) {
    return StarredAyahItem(
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      ayahText: ayahText ?? this.ayahText,
      surahName: surahName ?? this.surahName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StarredAyahItem &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => Object.hash(surahNumber, verseNumber);

  @override
  String toString() =>
      'StarredAyahItem($surahName $surahNumber:$verseNumber, page $pageNumber)';
}

