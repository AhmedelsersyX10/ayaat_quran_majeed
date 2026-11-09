/// Domain entity representing an Ayah's combined Quranic text and Tafsir explanation
/// for display in Tafsir Mode (Reference 17).
///
/// Pure Dart — no Flutter framework dependencies.
class AyahTafsir {
  /// Surah number (1 to 114).
  final int surahNumber;

  /// Ayah number within the Surah (1 to verse count).
  final int ayahNumber;

  /// Mushaf page number (1 to 604) where this Ayah resides.
  final int pageNumber;

  /// Quranic Arabic text of the verse.
  final String ayahText;

  /// Verse end symbol with the ayah number (e.g. " ﴿٦﴾ ").
  final String ayahEndSymbol;

  /// Arabic name of the Surah (e.g. "البَقَرَة").
  final String surahName;

  /// True if this is the first verse of the Surah (ayah 1), signaling a Surah header.
  final bool isFirstAyahOfSurah;

  /// The parsed explanation / translation text for this verse.
  final String tafsirText;

  /// Identifier of the active Tafsir book (e.g. 'ar_muyassar').
  final String bookId;

  /// Localized name of the active Tafsir book (e.g. 'التفسير الميسر').
  final String bookName;

  const AyahTafsir({
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
    required this.ayahText,
    required this.ayahEndSymbol,
    required this.surahName,
    required this.isFirstAyahOfSurah,
    required this.tafsirText,
    required this.bookId,
    required this.bookName,
  });

  AyahTafsir copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? pageNumber,
    String? ayahText,
    String? ayahEndSymbol,
    String? surahName,
    bool? isFirstAyahOfSurah,
    String? tafsirText,
    String? bookId,
    String? bookName,
  }) {
    return AyahTafsir(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      ayahText: ayahText ?? this.ayahText,
      ayahEndSymbol: ayahEndSymbol ?? this.ayahEndSymbol,
      surahName: surahName ?? this.surahName,
      isFirstAyahOfSurah: isFirstAyahOfSurah ?? this.isFirstAyahOfSurah,
      tafsirText: tafsirText ?? this.tafsirText,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahTafsir &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber &&
          pageNumber == other.pageNumber &&
          ayahText == other.ayahText &&
          ayahEndSymbol == other.ayahEndSymbol &&
          surahName == other.surahName &&
          isFirstAyahOfSurah == other.isFirstAyahOfSurah &&
          tafsirText == other.tafsirText &&
          bookId == other.bookId &&
          bookName == other.bookName;

  @override
  int get hashCode =>
      surahNumber.hashCode ^
      ayahNumber.hashCode ^
      pageNumber.hashCode ^
      ayahText.hashCode ^
      ayahEndSymbol.hashCode ^
      surahName.hashCode ^
      isFirstAyahOfSurah.hashCode ^
      tafsirText.hashCode ^
      bookId.hashCode ^
      bookName.hashCode;

  @override
  String toString() =>
      'AyahTafsir(surah: $surahNumber, ayah: $ayahNumber, page: $pageNumber, book: $bookId)';
}

