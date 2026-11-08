import '../entities/playback_session.dart';
import '../entities/playback_state.dart';

/// Pure Dart domain contract for the Quran recitation playback engine.
///
/// Responsible for coordinating audio stream playback, ayah-level timing
/// synchronization, repetition rules (Reference 40), and stop ranges (Reference 22).
abstract class PlaybackRepository {
  /// Continuous stream of playback session snapshots emitted during playback,
  /// seeking, buffering, ayah progression, and state transitions.
  Stream<PlaybackSession> get sessionStream;

  /// The current synchronous snapshot of the playback session.
  PlaybackSession get currentSession;

  /// Starts playback of a specific isolated ayah, or plays that ayah as the start
  /// of recitation up to the end of the surah.
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    RepeatSettings? repeatSettings,
  });

  /// Starts playback of an entire surah starting from [startAyah] (defaults to 1).
  Future<void> playSurah({
    required int surahNumber,
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  });

  /// Starts playback across an explicit [range] from (startSurah:startAyah)
  /// to (endSurah:endAyah), honoring [repeatSettings].
  Future<void> playRange({
    required PlaybackRange range,
    RepeatSettings? repeatSettings,
  });

  /// Dynamically updates the active playback range endpoint without interrupting
  /// playback if current position is within the new range, or starts playback if idle.
  Future<void> updateRange(PlaybackRange range);

  /// Pauses the active recitation.
  Future<void> pause();

  /// Resumes paused recitation.
  Future<void> resume();

  /// Stops recitation and resets engine to idle.
  Future<void> stop();

  /// Seeks to a specific [position] within the active surah audio track.
  Future<void> seek(Duration position);

  /// Seeks directly to the start timestamp of [ayahNumber] within the active surah.
  Future<void> seekToAyah(int ayahNumber);

  /// Dynamically updates the repetition settings without restarting the track.
  Future<void> setRepeatSettings(RepeatSettings settings);

  /// Releases audio engine resources.
  Future<void> dispose();
}

