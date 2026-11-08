import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';

/// Base abstract class for audio playback presentation state.
abstract class AudioPlaybackState {
  final PlaybackSession session;

  const AudioPlaybackState(this.session);

  /// Current playback status.
  PlaybackStatus get status => session.status;

  /// Active surah number.
  int get surahNumber => session.surahNumber;

  /// Current synchronized reciting ayah (1-based index), or null if in Basmala.
  int? get currentAyah => session.currentAyah;

  /// Active playback position.
  Duration get position => session.position;

  /// Total track duration.
  Duration get duration => session.duration;

  /// Buffered track duration.
  Duration get bufferedPosition => session.bufferedPosition;

  /// Whether audio is buffering from network.
  bool get isBuffering => session.isBuffering;

  /// Active reciter entity.
  Reciter? get reciter => session.reciter;

  /// Active moshaf edition entity.
  Moshaf? get moshaf => session.moshaf;

  /// Designated recitation range.
  PlaybackRange get range => session.range;

  /// Repetition counters and configuration.
  RepeatSettings get repeatSettings => session.repeatSettings;

  /// Whether verified ayah timing is active.
  bool get hasTiming => session.hasTiming;
}

/// Initial or stopped state with no active recitation.
class AudioPlaybackIdle extends AudioPlaybackState {
  const AudioPlaybackIdle([super.session = const PlaybackSession(status: PlaybackStatus.idle)]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackIdle && session == other.session;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() => 'AudioPlaybackIdle()';
}

/// State when audio source is being resolved, fetched, and buffered.
/// Reference 37 shows a loading spinner on the player button during this state.
class AudioPlaybackLoading extends AudioPlaybackState {
  const AudioPlaybackLoading(super.session);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackLoading && session == other.session;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() =>
      'AudioPlaybackLoading(surah: $surahNumber, ayah: $currentAyah)';
}

/// State when audio recitation is actively playing.
/// Verse follow-along highlight is active (Reference 37).
class AudioPlaybackPlaying extends AudioPlaybackState {
  const AudioPlaybackPlaying(super.session);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackPlaying && session == other.session;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() =>
      'AudioPlaybackPlaying(surah: $surahNumber, ayah: $currentAyah, pos: ${position.inSeconds}s)';
}

/// State when recitation is paused.
/// Keeps player card displayed with resume action icon (Reference 05).
class AudioPlaybackPaused extends AudioPlaybackState {
  const AudioPlaybackPaused(super.session);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackPaused && session == other.session;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() =>
      'AudioPlaybackPaused(surah: $surahNumber, ayah: $currentAyah, pos: ${position.inSeconds}s)';
}

/// State when the designated recitation range and repetitions have completed.
class AudioPlaybackCompleted extends AudioPlaybackState {
  const AudioPlaybackCompleted(super.session);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackCompleted && session == other.session;

  @override
  int get hashCode => session.hashCode;

  @override
  String toString() => 'AudioPlaybackCompleted(surah: $surahNumber)';
}

/// State when playback or network retrieval encounters an error.
class AudioPlaybackFailure extends AudioPlaybackState {
  final String message;

  const AudioPlaybackFailure(super.session, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlaybackFailure &&
          session == other.session &&
          message == other.message;

  @override
  int get hashCode => Object.hash(session, message);

  @override
  String toString() => 'AudioPlaybackFailure($message)';
}

