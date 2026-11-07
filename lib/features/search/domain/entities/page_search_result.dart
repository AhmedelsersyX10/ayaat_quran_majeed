/// Pure Dart domain entity representing a page navigation match.
class PageSearchResult {
  final int pageNumber;
  final int surahNumber;
  final int verseNumber;
  final String surahName;

  const PageSearchResult({
    required this.pageNumber,
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageSearchResult &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode =>
      pageNumber.hashCode ^ surahNumber.hashCode ^ verseNumber.hashCode;
}
