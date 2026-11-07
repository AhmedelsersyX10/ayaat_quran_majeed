/// Represents a specific Moshaf / Rewaya edition for a reciter.
///
/// Pure Dart — no Flutter framework dependencies.
class Moshaf {
  /// Unique identifier of this moshaf edition.
  ///
  /// Matches `read_id` in `https://www.mp3quran.net/api/v3/ayat_timing/reads`.
  final int id;

  /// Display name of the moshaf and rewaya (e.g. "حفص عن عاصم - مرتل").
  final String name;

  /// Base server URL for audio files (e.g. "https://cdn.mp3quran.net/audio/ibrahim-akhdar/r1/").
  final String server;

  /// Total count of surahs available in this moshaf (e.g. 114).
  final int surahTotal;

  /// Moshaf type classification from mp3quran API.
  final int moshafType;

  /// Available surah numbers for this moshaf (1 to 114).
  final List<int> surahList;

  /// Whether this moshaf edition is supported by verified ayah-level timing.
  final bool hasTiming;

  const Moshaf({
    required this.id,
    required this.name,
    required this.server,
    required this.surahTotal,
    required this.moshafType,
    required this.surahList,
    this.hasTiming = false,
  });

  /// Builds the remote streaming audio URL for surah [surahNumber] (1 to 114).
  ///
  /// The surah number is padded to 3 digits (e.g. "001.mp3", "114.mp3").
  String getSurahAudioUrl(int surahNumber) {
    final baseUrl = server.endsWith('/') ? server : '$server/';
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    return '$baseUrl$paddedSurah.mp3';
  }

  /// Whether this moshaf contains audio for [surahNumber].
  bool hasSurah(int surahNumber) => surahList.contains(surahNumber);

  Moshaf copyWith({
    int? id,
    String? name,
    String? server,
    int? surahTotal,
    int? moshafType,
    List<int>? surahList,
    bool? hasTiming,
  }) {
    return Moshaf(
      id: id ?? this.id,
      name: name ?? this.name,
      server: server ?? this.server,
      surahTotal: surahTotal ?? this.surahTotal,
      moshafType: moshafType ?? this.moshafType,
      surahList: surahList ?? this.surahList,
      hasTiming: hasTiming ?? this.hasTiming,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Moshaf &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          server == other.server &&
          surahTotal == other.surahTotal &&
          moshafType == other.moshafType &&
          hasTiming == other.hasTiming &&
          _listEquals(surahList, other.surahList);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        server,
        surahTotal,
        moshafType,
        hasTiming,
        Object.hashAll(surahList),
      );

  static bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Moshaf(id: $id, name: $name, timing: $hasTiming, surahs: ${surahList.length})';
}
