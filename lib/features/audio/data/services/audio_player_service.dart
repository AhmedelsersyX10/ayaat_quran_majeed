import 'dart:async';

/// Engine status of the underlying audio player hardware.
enum AudioEngineStatus {
  idle,
  loading,
  buffering,
  ready,
  playing,
  paused,
  completed,
}

/// Types of audio interruptions (calls, notifications, other media apps).
enum AudioInterruptionKind {
  pause,
  duck,
  resume,
}

/// Audio interruption event emitted when audio focus is altered or headphones unplugged.
class AudioEngineInterruption {
  final AudioInterruptionKind kind;
  final bool isTransient;

  const AudioEngineInterruption({
    required this.kind,
    this.isTransient = false,
  });

  @override
  String toString() =>
      'AudioEngineInterruption(kind: $kind, transient: $isTransient)';
}

/// Abstract hardware-independent contract for audio playback, audio session management,
/// and background media item synchronization.
abstract class AudioPlayerService {
  /// Stream of current playback positions.
  Stream<Duration> get positionStream;

  /// Stream of track total duration updates.
  Stream<Duration?> get durationStream;

  /// Stream of buffered duration updates.
  Stream<Duration> get bufferedPositionStream;

  /// Stream of player engine status changes.
  Stream<AudioEngineStatus> get statusStream;

  /// Stream of platform audio interruptions (phone calls, audio focus changes, headphone disconnects).
  Stream<AudioEngineInterruption> get interruptionStream;

  /// Stream emitted whenever an audio track reaches natural completion.
  Stream<void> get completedStream;

  /// Current synchronous playback position.
  Duration get position;

  /// Current synchronous total duration.
  Duration get duration;

  /// Whether audio is actively playing.
  bool get isPlaying;

  /// Initializes the audio session and registers background listeners.
  Future<void> init();

  /// Prepares and sets the audio source URI (file path or remote URL) with optional metadata.
  Future<void> setSource(
    String uri, {
    String? title,
    String? artist,
    String? albumArt,
  });

  /// Starts or resumes audio playback.
  Future<void> play();

  /// Pauses audio playback.
  Future<void> pause();

  /// Stops audio playback and resets engine.
  Future<void> stop();

  /// Seeks to a designated [position].
  Future<void> seek(Duration position);

  /// Releases audio engine and session resources.
  Future<void> dispose();
}

