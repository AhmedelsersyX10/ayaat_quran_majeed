/// Pure Dart domain entity representing a Quranic verse search match.
class VerseSearchResult {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final String originalText;
  final String surahName;
  final int score;

  const VerseSearchResult({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.originalText,
    required this.surahName,
    this.score = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseSearchResult &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber &&
          pageNumber == other.pageNumber;

  @override
  int get hashCode =>
      surahNumber.hashCode ^ verseNumber.hashCode ^ pageNumber.hashCode;
}
