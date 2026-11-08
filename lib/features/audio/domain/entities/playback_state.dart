/// Playback status representing the distinct states of the recitation engine.
enum PlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
  failure,
}

/// Settings and counters for repeating an individual ayah or a designated range.
///
/// Matches "إعدادات التلاوة" (Reference 40).
/// Pure Dart — no Flutter framework dependencies.
class RepeatSettings {
  /// Total times each ayah should be recited before moving to the next.
  /// A value of 1 means play once without repetition.
  final int repeatAyah;

  /// Total times the entire designated range should be repeated.
  /// A value of 1 means play once without repetition.
  final int repeatRange;

  /// 1-based counter tracking the current repeat cycle of the active ayah.
  final int currentAyahRepeat;

  /// 1-based counter tracking the current repeat cycle of the entire range.
  final int currentRangeRepeat;

  const RepeatSettings({
    this.repeatAyah = 1,
    this.repeatRange = 1,
    this.currentAyahRepeat = 1,
    this.currentRangeRepeat = 1,
  })  : assert(repeatAyah >= 1, 'repeatAyah must be at least 1'),
        assert(repeatRange >= 1, 'repeatRange must be at least 1'),
        assert(currentAyahRepeat >= 1, 'currentAyahRepeat must be at least 1'),
        assert(currentRangeRepeat >= 1, 'currentRangeRepeat must be at least 1');

  RepeatSettings copyWith({
    int? repeatAyah,
    int? repeatRange,
    int? currentAyahRepeat,
    int? currentRangeRepeat,
  }) {
    return RepeatSettings(
      repeatAyah: repeatAyah ?? this.repeatAyah,
      repeatRange: repeatRange ?? this.repeatRange,
      currentAyahRepeat: currentAyahRepeat ?? this.currentAyahRepeat,
      currentRangeRepeat: currentRangeRepeat ?? this.currentRangeRepeat,
    );
  }

  /// Whether current ayah repeat count has reached its designated limit.
  bool get isAyahRepeatComplete => currentAyahRepeat >= repeatAyah;

  /// Whether current range repeat count has reached its designated limit.
  bool get isRangeRepeatComplete => currentRangeRepeat >= repeatRange;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatSettings &&
          runtimeType == other.runtimeType &&
          repeatAyah == other.repeatAyah &&
          repeatRange == other.repeatRange &&
          currentAyahRepeat == other.currentAyahRepeat &&
          currentRangeRepeat == other.currentRangeRepeat;

  @override
  int get hashCode => Object.hash(
        repeatAyah,
        repeatRange,
        currentAyahRepeat,
        currentRangeRepeat,
      );

  @override
  String toString() =>
      'RepeatSettings(ayah: $currentAyahRepeat/$repeatAyah, range: $currentRangeRepeat/$repeatRange)';
}

/// Represents the playback recitation range from (startSurah:startAyah) to (endSurah:endAyah).
///
/// Matches "تشغيل إلى..." (Reference 22) and "إعدادات التلاوة" (Reference 40).
/// Pure Dart — no Flutter framework dependencies.
class PlaybackRange {
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  const PlaybackRange({
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  })  : assert(startSurah >= 1 && startSurah <= 114),
        assert(endSurah >= 1 && endSurah <= 114),
        assert(startAyah >= 1),
        assert(endAyah >= 1),
        assert(
          startSurah < endSurah ||
              (startSurah == endSurah && startAyah <= endAyah),
          'End verse cannot precede start verse: $startSurah:$startAyah to $endSurah:$endAyah',
        );

  /// Validates whether the given boundaries form an admissible playback range
  /// where the end point is not before the start point.
  static bool isValidRange(
    int startSurah,
    int startAyah,
    int endSurah,
    int endAyah,
  ) {
    if (startSurah < 1 || startSurah > 114) return false;
    if (endSurah < 1 || endSurah > 114) return false;
    if (startAyah < 1 || endAyah < 1) return false;
    if (startSurah > endSurah) return false;
    if (startSurah == endSurah && startAyah > endAyah) return false;
    return true;
  }

  /// Validated factory that throws [ArgumentError] if boundaries are invalid.
  factory PlaybackRange.validated({
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
  }) {
    if (!isValidRange(startSurah, startAyah, endSurah, endAyah)) {
      throw ArgumentError(
        'Invalid playback range: $startSurah:$startAyah to $endSurah:$endAyah',
      );
    }
    return PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
    );
  }

  /// Convenient factory to play a single isolated ayah.
  factory PlaybackRange.singleAyah(int surah, int ayah) {
    return PlaybackRange(
      startSurah: surah,
      startAyah: ayah,
      endSurah: surah,
      endAyah: ayah,
    );
  }

  /// Convenient factory to play an entire surah or from [startAyah] to the end of the surah.
  factory PlaybackRange.surah(int surah, int totalAyat, {int startAyah = 1}) {
    return PlaybackRange(
      startSurah: surah,
      startAyah: startAyah,
      endSurah: surah,
      endAyah: totalAyat,
    );
  }

  /// Convenient factory to play from [startSurah]:[startAyah] to the end of a given page.
  factory PlaybackRange.page({
    required int startSurah,
    required int startAyah,
    required int lastSurahOnPage,
    required int lastAyahOnPage,
  }) {
    return PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: lastSurahOnPage,
      endAyah: lastAyahOnPage,
    );
  }

  /// Convenient factory to play from [startSurah]:[startAyah] to the end of the current surah.
  factory PlaybackRange.endOfSurah({
    required int startSurah,
    required int startAyah,
    required int totalAyatInSurah,
  }) {
    return PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: startSurah,
      endAyah: totalAyatInSurah,
    );
  }

  /// Convenient factory for continuous recitation up to the end of the Quran (114:6).
  factory PlaybackRange.continuous({
    required int startSurah,
    required int startAyah,
  }) {
    return PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: 114,
      endAyah: 6,
    );
  }

  /// Custom range factory.
  factory PlaybackRange.custom({
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
  }) {
    return PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
    );
  }

  /// Creates a copy of this range with a new endpoint, enforcing end-before-start.
  PlaybackRange copyWithNewEnd({
    required int endSurah,
    required int endAyah,
  }) {
    return PlaybackRange.validated(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
    );
  }

  /// Creates a copy of this range updating the start position to the current recitation position.
  PlaybackRange withCurrentPositionAsStart({
    required int currentSurah,
    required int currentAyah,
  }) {
    return PlaybackRange.validated(
      startSurah: currentSurah,
      startAyah: currentAyah,
      endSurah: endSurah,
      endAyah: endAyah,
    );
  }

  /// Whether the range is restricted to a single verse.
  bool get isSingleAyah => startSurah == endSurah && startAyah == endAyah;

  /// Whether the range is contained within a single surah.
  bool get isSingleSurah => startSurah == endSurah;

  /// Checks if [surah] and [ayah] fall within this range (inclusive).
  bool contains(int surah, int ayah) {
    if (surah < startSurah || surah > endSurah) return false;
    if (surah == startSurah && ayah < startAyah) return false;
    if (surah == endSurah && ayah > endAyah) return false;
    return true;
  }

  /// Checks if [surah] and [ayah] match the starting verse.
  bool isStart(int surah, int ayah) =>
      surah == startSurah && ayah == startAyah;

  /// Checks if [surah] and [ayah] represent the final verse in this range.
  bool isLastAyah(int surah, int ayah) =>
      surah == endSurah && ayah == endAyah;

  /// Checks if [surah] and [ayah] represent the final verse in this range (alias).
  bool isEnd(int surah, int ayah) => isLastAyah(surah, ayah);

  /// Checks if [surah] and [ayah] precede the start of this range.
  bool isBeforeStart(int surah, int ayah) {
    if (surah < startSurah) return true;
    if (surah == startSurah && ayah < startAyah) return true;
    return false;
  }

  /// Checks if [surah] and [ayah] are past the end of this range.
  bool isPastEnd(int surah, int ayah) {
    if (surah > endSurah) return true;
    if (surah == endSurah && ayah > endAyah) return true;
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackRange &&
          runtimeType == other.runtimeType &&
          startSurah == other.startSurah &&
          startAyah == other.startAyah &&
          endSurah == other.endSurah &&
          endAyah == other.endAyah;

  @override
  int get hashCode => Object.hash(startSurah, startAyah, endSurah, endAyah);

  @override
  String toString() =>
      'PlaybackRange($startSurah:$startAyah -> $endSurah:$endAyah)';
}
