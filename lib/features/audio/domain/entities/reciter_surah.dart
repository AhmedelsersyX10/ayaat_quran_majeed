/// Represents surah audio information for a specific reciter and moshaf edition.
///
/// Used for listing surahs grouped by Juz on the Reciter page (Reference 36).
///
/// Pure Dart — no Flutter framework dependencies.
class ReciterSurah {
  /// Surah number (1 to 114).
  final int surahNumber;

  /// Surah Arabic name (e.g. "الفَاتِحة").
  final String surahName;

  /// Starting Juz number for this surah (1 to 30).
  final int juzNumber;

  /// Total count of verses in this surah.
  final int verseCount;

  /// Direct streaming audio URL.
  final String audioUrl;

  /// Whether the surah MP3 file has been downloaded to local device storage.
  final bool isDownloaded;

  /// Absolute file system path to the downloaded MP3 file, if downloaded.
  final String? localFilePath;

  /// Whether verified ayah-level timing is available for this surah.
  final bool hasTiming;

  const ReciterSurah({
    required this.surahNumber,
    required this.surahName,
    required this.juzNumber,
    required this.verseCount,
    required this.audioUrl,
    this.isDownloaded = false,
    this.localFilePath,
    this.hasTiming = false,
  });

  /// The playable URI: local file path if downloaded, remote streaming URL otherwise.
  String get playableUri => (isDownloaded && localFilePath != null)
      ? localFilePath!
      : audioUrl;

  ReciterSurah copyWith({
    int? surahNumber,
    String? surahName,
    int? juzNumber,
    int? verseCount,
    String? audioUrl,
    bool? isDownloaded,
    String? localFilePath,
    bool? hasTiming,
  }) {
    return ReciterSurah(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      juzNumber: juzNumber ?? this.juzNumber,
      verseCount: verseCount ?? this.verseCount,
      audioUrl: audioUrl ?? this.audioUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      hasTiming: hasTiming ?? this.hasTiming,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterSurah &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          surahName == other.surahName &&
          juzNumber == other.juzNumber &&
          verseCount == other.verseCount &&
          audioUrl == other.audioUrl &&
          isDownloaded == other.isDownloaded &&
          localFilePath == other.localFilePath &&
          hasTiming == other.hasTiming;

  @override
  int get hashCode => Object.hash(
        surahNumber,
        surahName,
        juzNumber,
        verseCount,
        audioUrl,
        isDownloaded,
        localFilePath,
        hasTiming,
      );

  @override
  String toString() =>
      'ReciterSurah($surahNumber: $surahName, downloaded: $isDownloaded, timing: $hasTiming)';
}
