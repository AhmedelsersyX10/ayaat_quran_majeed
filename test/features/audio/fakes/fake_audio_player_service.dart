import 'dart:async';
import 'package:ayaat_quran_majeed/features/audio/data/services/audio_player_service.dart';

/// In-memory, deterministic fake implementation of [AudioPlayerService] for unit testing.
///
/// Has zero platform channel or physical hardware dependencies and allows tests
/// to control time, position, status, and interruptions deterministically.
class FakeAudioPlayerService implements AudioPlayerService {
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  final StreamController<Duration> _bufferedPositionController =
      StreamController<Duration>.broadcast();
  final StreamController<AudioEngineStatus> _statusController =
      StreamController<AudioEngineStatus>.broadcast();
  final StreamController<AudioEngineInterruption> _interruptionController =
      StreamController<AudioEngineInterruption>.broadcast();
  final StreamController<void> _completedController =
      StreamController<void>.broadcast();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  AudioEngineStatus _status = AudioEngineStatus.idle;
  bool _isPlaying = false;

  // Invocations recording
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  final List<Duration> seekCalls = [];
  String? lastSourceUri;
  String? lastTitle;
  String? lastArtist;
  bool isDisposed = false;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<Duration> get bufferedPositionStream =>
      _bufferedPositionController.stream;

  @override
  Stream<AudioEngineStatus> get statusStream => _statusController.stream;

  @override
  Stream<AudioEngineInterruption> get interruptionStream =>
      _interruptionController.stream;

  @override
  Stream<void> get completedStream => _completedController.stream;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  Duration get bufferedPosition => _bufferedPosition;

  AudioEngineStatus get status => _status;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> init() async {}

  @override
  Future<void> setSource(
    String uri, {
    String? title,
    String? artist,
    String? albumArt,
  }) async {
    lastSourceUri = uri;
    lastTitle = title;
    lastArtist = artist;
    _status = AudioEngineStatus.ready;
    _statusController.add(_status);
  }

  @override
  Future<void> play() async {
    playCalls++;
    _isPlaying = true;
    _status = AudioEngineStatus.playing;
    _statusController.add(_status);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _isPlaying = false;
    _status = AudioEngineStatus.paused;
    _statusController.add(_status);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _isPlaying = false;
    _position = Duration.zero;
    _status = AudioEngineStatus.idle;
    _statusController.add(_status);
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalls.add(position);
    _position = position;
    _positionController.add(position);
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await _positionController.close();
    await _durationController.close();
    await _bufferedPositionController.close();
    await _statusController.close();
    await _interruptionController.close();
    await _completedController.close();
  }

  // --- Test Simulation Controls ---

  void simulatePosition(Duration position) {
    _position = position;
    if (!_positionController.isClosed) {
      _positionController.add(position);
    }
  }

  void simulateDuration(Duration duration) {
    _duration = duration;
    if (!_durationController.isClosed) {
      _durationController.add(duration);
    }
  }

  void simulateBufferedPosition(Duration bufferedPosition) {
    _bufferedPosition = bufferedPosition;
    if (!_bufferedPositionController.isClosed) {
      _bufferedPositionController.add(bufferedPosition);
    }
  }

  void simulateStatus(AudioEngineStatus status) {
    _status = status;
    _isPlaying = status == AudioEngineStatus.playing;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  void simulateCompleted() {
    _isPlaying = false;
    _status = AudioEngineStatus.completed;
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
    if (!_completedController.isClosed) {
      _completedController.add(null);
    }
  }

  void simulateInterruption(AudioEngineInterruption interruption) {
    if (!_interruptionController.isClosed) {
      _interruptionController.add(interruption);
    }
  }

  void simulateHeadphoneUnplug() {
    simulateInterruption(const AudioEngineInterruption(
      kind: AudioInterruptionKind.pause,
      isTransient: false,
    ));
  }
}

