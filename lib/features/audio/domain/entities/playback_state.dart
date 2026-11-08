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
        assert(endAyah >= 1);

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

  /// Whether the range is restricted to a single verse.
  bool get isSingleAyah => startSurah == endSurah && startAyah == endAyah;

  /// Whether the range is contained within a single surah.
  bool get isSingleSurah => startSurah == endSurah;

  /// Checks if [surah] and [ayah] fall within this range.
  bool contains(int surah, int ayah) {
    if (surah < startSurah || surah > endSurah) return false;
    if (surah == startSurah && ayah < startAyah) return false;
    if (surah == endSurah && ayah > endAyah) return false;
    return true;
  }

  /// Checks if [surah] and [ayah] represent the final verse in this range.
  bool isLastAyah(int surah, int ayah) =>
      surah == endSurah && ayah == endAyah;

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
