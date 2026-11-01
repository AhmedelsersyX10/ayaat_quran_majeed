class QuranSearchResult {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final String originalText;
  final String surahName;
  final int score;

  const QuranSearchResult({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.originalText,
    required this.surahName,
    this.score = 0,
  });
}
