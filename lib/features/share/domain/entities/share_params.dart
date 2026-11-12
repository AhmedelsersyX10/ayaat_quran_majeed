/// Configuration parameters for formatting and sharing Quranic verses.
///
/// Pure Dart domain model independent of Flutter UI/presentation rendering.
class ShareParams {
  final int surahNumber;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final int pageNumber;
  final bool withoutTashkeel;
  final bool includeTafsir;
  final String? tafsirText;
  final String? tafsirBookName;
  final bool includeAppBranding;
  final String? noteText;

  const ShareParams({
    required this.surahNumber,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    this.pageNumber = 1,
    this.withoutTashkeel = false,
    this.includeTafsir = false,
    this.tafsirText,
    this.tafsirBookName = 'التفسير الميسر',
    this.includeAppBranding = true,
    this.noteText,
  });

  ShareParams copyWith({
    int? surahNumber,
    String? surahName,
    int? fromAyah,
    int? toAyah,
    int? pageNumber,
    bool? withoutTashkeel,
    bool? includeTafsir,
    String? tafsirText,
    String? tafsirBookName,
    bool? includeAppBranding,
    String? noteText,
  }) {
    return ShareParams(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      pageNumber: pageNumber ?? this.pageNumber,
      withoutTashkeel: withoutTashkeel ?? this.withoutTashkeel,
      includeTafsir: includeTafsir ?? this.includeTafsir,
      tafsirText: tafsirText ?? this.tafsirText,
      tafsirBookName: tafsirBookName ?? this.tafsirBookName,
      includeAppBranding: includeAppBranding ?? this.includeAppBranding,
      noteText: noteText ?? this.noteText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareParams &&
        other.surahNumber == surahNumber &&
        other.surahName == surahName &&
        other.fromAyah == fromAyah &&
        other.toAyah == toAyah &&
        other.pageNumber == pageNumber &&
        other.withoutTashkeel == withoutTashkeel &&
        other.includeTafsir == includeTafsir &&
        other.tafsirText == tafsirText &&
        other.tafsirBookName == tafsirBookName &&
        other.includeAppBranding == includeAppBranding &&
        other.noteText == noteText;
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    surahName,
    fromAyah,
    toAyah,
    pageNumber,
    withoutTashkeel,
    includeTafsir,
    tafsirText,
    tafsirBookName,
    includeAppBranding,
    noteText,
  );
}
