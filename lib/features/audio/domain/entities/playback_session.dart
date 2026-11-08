import 'moshaf.dart';
import 'playback_state.dart';
import 'reciter.dart';

/// Immutable domain snapshot of the active Quran recitation session.
///
/// Pure Dart — no Flutter framework dependencies.
class PlaybackSession {
  /// Current status of the playback engine.
  final PlaybackStatus status;

  /// Active surah number currently loaded in the audio engine (1 to 114).
  final int surahNumber;

  /// Active reciting ayah (1-based index) synchronized via audio timing,
  /// or `null` if during Basmala / intro or if timing is unavailable.
  final int? currentAyah;

  /// Current playback position in the active surah track.
  final Duration position;

  /// Total duration of the active surah audio track.
  final Duration duration;

  /// Buffered position of the track.
  final Duration bufferedPosition;

  /// Whether the player is currently buffering data from network.
  final bool isBuffering;

  /// Selected reciter, if resolved.
  final Reciter? reciter;

  /// Selected moshaf edition, if resolved.
  final Moshaf? moshaf;

  /// Designated playback recitation range (start to end verse).
  final PlaybackRange range;

  /// Repetition counters and configuration (Reference 40).
  final RepeatSettings repeatSettings;

  /// Whether verified ayah timing is active for this recitation.
  final bool hasTiming;

  /// Human-readable error message if [status] == [PlaybackStatus.failure].
  final String? errorMessage;

  const PlaybackSession({
    this.status = PlaybackStatus.idle,
    this.surahNumber = 1,
    this.currentAyah,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isBuffering = false,
    this.reciter,
    this.moshaf,
    this.range = const PlaybackRange(
      startSurah: 1,
      startAyah: 1,
      endSurah: 1,
      endAyah: 7,
    ),
    this.repeatSettings = const RepeatSettings(),
    this.hasTiming = false,
    this.errorMessage,
  });

  /// Initial idle session placeholder.
  factory PlaybackSession.initial({
    Reciter? reciter,
    Moshaf? moshaf,
  }) {
    return PlaybackSession(
      status: PlaybackStatus.idle,
      reciter: reciter,
      moshaf: moshaf,
    );
  }

  PlaybackSession copyWith({
    PlaybackStatus? status,
    int? surahNumber,
    int? Function()? currentAyah,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    bool? isBuffering,
    Reciter? reciter,
    Moshaf? moshaf,
    PlaybackRange? range,
    RepeatSettings? repeatSettings,
    bool? hasTiming,
    String? Function()? errorMessage,
  }) {
    return PlaybackSession(
      status: status ?? this.status,
      surahNumber: surahNumber ?? this.surahNumber,
      currentAyah: currentAyah != null ? currentAyah() : this.currentAyah,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isBuffering: isBuffering ?? this.isBuffering,
      reciter: reciter ?? this.reciter,
      moshaf: moshaf ?? this.moshaf,
      range: range ?? this.range,
      repeatSettings: repeatSettings ?? this.repeatSettings,
      hasTiming: hasTiming ?? this.hasTiming,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  /// Whether playback is actively running or loading.
  bool get isActive =>
      status == PlaybackStatus.playing ||
      status == PlaybackStatus.loading ||
      status == PlaybackStatus.paused;

  /// Whether the session is currently playing audio.
  bool get isPlaying => status == PlaybackStatus.playing;

  /// Whether the session is paused.
  bool get isPaused => status == PlaybackStatus.paused;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackSession &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          surahNumber == other.surahNumber &&
          currentAyah == other.currentAyah &&
          position == other.position &&
          duration == other.duration &&
          bufferedPosition == other.bufferedPosition &&
          isBuffering == other.isBuffering &&
          reciter == other.reciter &&
          moshaf == other.moshaf &&
          range == other.range &&
          repeatSettings == other.repeatSettings &&
          hasTiming == other.hasTiming &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        status,
        surahNumber,
        currentAyah,
        position,
        duration,
        bufferedPosition,
        isBuffering,
        reciter,
        moshaf,
        range,
        repeatSettings,
        hasTiming,
        errorMessage,
      );

  @override
  String toString() =>
      'PlaybackSession(status: $status, surah: $surahNumber, ayah: $currentAyah, pos: ${position.inSeconds}s, timing: $hasTiming)';
}
