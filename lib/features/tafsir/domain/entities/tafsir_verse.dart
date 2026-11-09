/// Domain entity representing the Tafsir or translation content for a single verse.
/// Pure Dart — no Flutter framework dependencies.
class TafsirVerse {
  /// Surah number (1 to 114).
  final int surahNumber;

  /// Ayah number within the Surah (1 to verse count).
  final int ayahNumber;

  /// Clean, formatted tafsir or translation text.
  final String text;

  /// Identifier of the source book.
  final String bookId;

  const TafsirVerse({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.bookId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirVerse &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber &&
          text == other.text &&
          bookId == other.bookId;

  @override
  int get hashCode =>
      surahNumber.hashCode ^
      ayahNumber.hashCode ^
      text.hashCode ^
      bookId.hashCode;

  @override
  String toString() =>
      'TafsirVerse(bookId: $bookId, surah: $surahNumber, ayah: $ayahNumber)';
}

