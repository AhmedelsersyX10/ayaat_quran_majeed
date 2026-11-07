/// Represents the timing interval for an ayah within a surah audio track.
///
/// Units are in milliseconds ([ms]).
///
/// Pure Dart — no Flutter framework dependencies.
class AyahTiming {
  /// Ayah number (1-based index).
  ///
  /// Note: A value of `0` represents the Basmala track where explicitly indexed
  /// by the timing API.
  final int ayah;

  /// Start timestamp of the ayah recitation in milliseconds.
  final int startTimeMs;

  /// End timestamp of the ayah recitation in milliseconds.
  final int endTimeMs;

  const AyahTiming({
    required this.ayah,
    required this.startTimeMs,
    required this.endTimeMs,
  });

  /// Returns true if [positionMs] falls within this ayah's playback window:
  /// `positionMs >= startTimeMs && positionMs < endTimeMs`.
  bool containsPosition(int positionMs) =>
      positionMs >= startTimeMs && positionMs < endTimeMs;

  /// Duration from beginning of track to ayah start.
  Duration get startDuration => Duration(milliseconds: startTimeMs);

  /// Duration from beginning of track to ayah end.
  Duration get endDuration => Duration(milliseconds: endTimeMs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahTiming &&
          runtimeType == other.runtimeType &&
          ayah == other.ayah &&
          startTimeMs == other.startTimeMs &&
          endTimeMs == other.endTimeMs;

  @override
  int get hashCode => Object.hash(ayah, startTimeMs, endTimeMs);

  @override
  String toString() =>
      'AyahTiming(ayah: $ayah, start: $startTimeMs ms, end: $endTimeMs ms)';
}

/// Represents the collection of ayah timings for an entire surah in a given moshaf read.
/// Pure Dart — no Flutter framework dependencies.
class SurahTiming {
  /// Surah number (1 to 114).
  final int surahNumber;

  /// Identifier of the moshaf read matching `ayat_timing/reads`.
  final int readId;

  /// List of ayah timing intervals ordered by recitation sequence.
  final List<AyahTiming> ayahTimings;

  const SurahTiming({
    required this.surahNumber,
    required this.readId,
    required this.ayahTimings,
  });

  /// Whether verified timing data exists for this surah.
  bool get hasTiming => ayahTimings.isNotEmpty;

  /// Returns the ayah number (1 to N) currently reciting at [positionMs].
  ///
  /// Returns `null` if:
  /// - No timing data is available ([hasTiming] is false).
  /// - The current position is before the first ayah or in a Basmala interval (`ayah == 0`).
  /// - The position is beyond the last ayah interval.
  int? findAyahAt(int positionMs) {
    if (ayahTimings.isEmpty) return null;

    for (final timing in ayahTimings) {
      if (timing.containsPosition(positionMs)) {
        // Ayah 0 represents Basmala / intro, which is not a highlighted Quran ayah.
        return timing.ayah == 0 ? null : timing.ayah;
      }
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahTiming &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          readId == other.readId &&
          _listEquals(ayahTimings, other.ayahTimings);

  @override
  int get hashCode => Object.hash(
        surahNumber,
        readId,
        Object.hashAll(ayahTimings),
      );

  static bool _listEquals(List<AyahTiming> a, List<AyahTiming> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'SurahTiming(surah: $surahNumber, read: $readId, count: ${ayahTimings.length})';
}
