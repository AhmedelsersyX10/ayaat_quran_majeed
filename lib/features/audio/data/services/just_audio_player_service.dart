import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_service.dart';

/// Concrete production implementation of [AudioPlayerService] utilizing
/// [AudioPlayer] from `just_audio`, [AudioSession] for focus/interruptions,
/// and [MediaItem] tags for native background notification metadata.
class JustAudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player;
  AudioSession? _session;

  final StreamController<AudioEngineStatus> _statusController =
      StreamController<AudioEngineStatus>.broadcast();
  final StreamController<AudioEngineInterruption> _interruptionController =
      StreamController<AudioEngineInterruption>.broadcast();
  final StreamController<void> _completedController =
      StreamController<void>.broadcast();

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;

  bool _wasPlayingBeforeInterruption = false;
  bool _isInitialized = false;

  JustAudioPlayerServiceImpl({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<AudioEngineStatus> get statusStream => _statusController.stream;

  @override
  Stream<AudioEngineInterruption> get interruptionStream =>
      _interruptionController.stream;

  @override
  Stream<void> get completedStream => _completedController.stream;

  @override
  Duration get position => _player.position;

  @override
  Duration get duration => _player.duration ?? Duration.zero;

  @override
  bool get isPlaying => _player.playing;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _session = await AudioSession.instance;
      await _session?.configure(const AudioSessionConfiguration.music());

      // 1. Listen for audio interruptions (e.g. incoming calls, other audio apps)
      _interruptionSub = _session?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _interruptionController.add(const AudioEngineInterruption(
                kind: AudioInterruptionKind.duck,
                isTransient: true,
              ));
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _wasPlayingBeforeInterruption = _player.playing;
              _interruptionController.add(const AudioEngineInterruption(
                kind: AudioInterruptionKind.pause,
                isTransient: true,
              ));
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _interruptionController.add(const AudioEngineInterruption(
                kind: AudioInterruptionKind.resume,
                isTransient: true,
              ));
              break;
            case AudioInterruptionType.pause:
              if (_wasPlayingBeforeInterruption) {
                _interruptionController.add(const AudioEngineInterruption(
                  kind: AudioInterruptionKind.resume,
                  isTransient: true,
                ));
                play();
              }
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // 2. Listen for headphone disconnects / unplugging (becoming noisy)
      _becomingNoisySub = _session?.becomingNoisyEventStream.listen((_) {
        _interruptionController.add(const AudioEngineInterruption(
          kind: AudioInterruptionKind.pause,
          isTransient: false,
        ));
        pause();
      });
    } catch (_) {
      // AudioSession may not be available on mock/test environments
    }

    // 3. Map just_audio player states to domain AudioEngineStatus
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final status = _mapPlayerStateToStatus(playerState);
      _statusController.add(status);

      if (playerState.processingState == ProcessingState.completed) {
        _completedController.add(null);
      }
    });

    _isInitialized = true;
  }

  AudioEngineStatus _mapPlayerStateToStatus(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        return AudioEngineStatus.idle;
      case ProcessingState.loading:
        return AudioEngineStatus.loading;
      case ProcessingState.buffering:
        return AudioEngineStatus.buffering;
      case ProcessingState.ready:
        return state.playing
            ? AudioEngineStatus.playing
            : AudioEngineStatus.paused;
      case ProcessingState.completed:
        return AudioEngineStatus.completed;
    }
  }

  @override
  Future<void> setSource(
    String uri, {
    String? title,
    String? artist,
    String? albumArt,
  }) async {
    await init();

    final mediaItem = MediaItem(
      id: uri,
      title: title ?? 'القرآن الكريم',
      artist: artist ?? 'تلاوة',
      artUri: albumArt != null ? Uri.tryParse(albumArt) : null,
    );

    final AudioSource source;
    if (uri.startsWith('file://')) {
      source = AudioSource.uri(
        Uri.parse(uri),
        tag: mediaItem,
      );
    } else if (uri.startsWith('/') || uri.startsWith('C:\\')) {
      source = AudioSource.file(
        uri,
        tag: mediaItem,
      );
    } else {
      source = AudioSource.uri(
        Uri.parse(uri),
        tag: mediaItem,
      );
    }

    await _player.setAudioSource(source);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _interruptionSub?.cancel();
    await _becomingNoisySub?.cancel();
    await _player.dispose();
    await _statusController.close();
    await _interruptionController.close();
    await _completedController.close();
  }
}

