import 'dart:async';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  PlaybackSession _current = const PlaybackSession(status: PlaybackStatus.idle);

  int playAyahCalls = 0;
  int playSurahCalls = 0;
  int playRangeCalls = 0;
  int updateRangeCalls = 0;
  int configureRangeCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;
  Duration? lastSeekPosition;
  int? lastSeekAyah;
  RepeatSettings? lastRepeatSettings;

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _current;

  void emitSession(PlaybackSession session) {
    _current = session;
    _controller.add(session);
  }

  @override
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    RepeatSettings? repeatSettings,
  }) async {
    playAyahCalls++;
    emitSession(_current.copyWith(
      status: PlaybackStatus.playing,
      surahNumber: surahNumber,
      currentAyah: () => ayahNumber,
    ));
  }

  @override
  Future<void> playSurah({
    required int surahNumber,
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  }) async {
    playSurahCalls++;
    emitSession(_current.copyWith(
      status: PlaybackStatus.playing,
      surahNumber: surahNumber,
      currentAyah: () => startAyah,
    ));
  }

  @override
  Future<void> playRange({
    required PlaybackRange range,
    RepeatSettings? repeatSettings,
  }) async {
    playRangeCalls++;
    emitSession(_current.copyWith(
      status: PlaybackStatus.playing,
      surahNumber: range.startSurah,
      currentAyah: () => range.startAyah,
      range: range,
    ));
  }

  @override
  Future<void> updateRange(PlaybackRange range) async {
    updateRangeCalls++;
    emitSession(_current.copyWith(
      range: range,
    ));
  }

  @override
  Future<void> configureRange(PlaybackRange range) async {
    configureRangeCalls++;
    emitSession(_current.copyWith(
      range: range,
    ));
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    emitSession(_current.copyWith(status: PlaybackStatus.paused));
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
    emitSession(_current.copyWith(status: PlaybackStatus.playing));
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    emitSession(const PlaybackSession(status: PlaybackStatus.idle));
  }

  @override
  Future<void> seek(Duration position) async {
    lastSeekPosition = position;
    emitSession(_current.copyWith(position: position));
  }

  @override
  Future<void> seekToAyah(int ayahNumber) async {
    lastSeekAyah = ayahNumber;
    emitSession(_current.copyWith(currentAyah: () => ayahNumber));
  }

  @override
  Future<void> setRepeatSettings(RepeatSettings settings) async {
    lastRepeatSettings = settings;
    emitSession(_current.copyWith(repeatSettings: settings));
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late MockPlaybackRepository mockRepository;
  late AudioPlaybackCubit cubit;

  setUp(() {
    mockRepository = MockPlaybackRepository();
    cubit = AudioPlaybackCubit(playbackRepository: mockRepository);
  });

  tearDown(() async {
    await cubit.close();
    await mockRepository.dispose();
  });

  group('AudioPlaybackCubit State Transitions & Controls', () {
    test('initial state is AudioPlaybackIdle', () {
      expect(cubit.state, isA<AudioPlaybackIdle>());
      expect(cubit.state.status, PlaybackStatus.idle);
      expect(cubit.state.currentAyah, isNull);
    });

    test('playAyah triggers repository and emits AudioPlaybackPlaying', () async {
      await cubit.playAyah(2, 255);

      expect(mockRepository.playAyahCalls, 1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());
      expect(cubit.state.surahNumber, 2);
      expect(cubit.state.currentAyah, 255);
    });

    test('playSurah triggers repository and emits AudioPlaybackPlaying', () async {
      await cubit.playSurah(1);

      expect(mockRepository.playSurahCalls, 1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());
      expect(cubit.state.surahNumber, 1);
      expect(cubit.state.currentAyah, 1);
    });

    test('playRange triggers repository with specified range', () async {
      final range = PlaybackRange.custom(
        startSurah: 2,
        startAyah: 1,
        endSurah: 2,
        endAyah: 5,
      );
      await cubit.playRange(range);

      expect(mockRepository.playRangeCalls, 1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());
      expect(cubit.state.range, equals(range));
    });

    test('pause and resume emit AudioPlaybackPaused and AudioPlaybackPlaying', () async {
      await cubit.playSurah(1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());

      await cubit.pause();
      expect(mockRepository.pauseCalls, 1);
      expect(cubit.state, isA<AudioPlaybackPaused>());

      await cubit.resume();
      expect(mockRepository.resumeCalls, 1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());
    });

    test('stop resets state to AudioPlaybackIdle', () async {
      await cubit.playSurah(1);
      expect(cubit.state, isA<AudioPlaybackPlaying>());

      await cubit.stop();
      expect(mockRepository.stopCalls, 1);
      expect(cubit.state, isA<AudioPlaybackIdle>());
    });

    test('seek and seekToAyah delegate to repository', () async {
      await cubit.seek(const Duration(seconds: 45));
      expect(mockRepository.lastSeekPosition, const Duration(seconds: 45));

      await cubit.seekToAyah(7);
      expect(mockRepository.lastSeekAyah, 7);
    });

    test('completed session emits AudioPlaybackCompleted', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.completed,
        surahNumber: 1,
      ));
      await pumpEventQueue();

      expect(cubit.state, isA<AudioPlaybackCompleted>());
    });

    test('failure session emits AudioPlaybackFailure with error message', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.failure,
        errorMessage: 'Network timeout during playback',
      ));
      await pumpEventQueue();

      expect(cubit.state, isA<AudioPlaybackFailure>());
      final failure = cubit.state as AudioPlaybackFailure;
      expect(failure.message, 'Network timeout during playback');
    });

    test('skipNextAyah seeks to currentAyah + 1', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 3,
      ));
      await pumpEventQueue();

      await cubit.skipNextAyah();
      expect(mockRepository.lastSeekAyah, equals(4));
    });

    test('skipPreviousAyah seeks to currentAyah - 1 or clamped to 1', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 3,
      ));
      await pumpEventQueue();

      await cubit.skipPreviousAyah();
      expect(mockRepository.lastSeekAyah, equals(2));

      // At Ayah 1, seek to 1
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 1,
      ));
      await pumpEventQueue();

      await cubit.skipPreviousAyah();
      expect(mockRepository.lastSeekAyah, equals(1));
    });

    test('loading session emits AudioPlaybackLoading', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.loading,
        surahNumber: 2,
      ));
      await pumpEventQueue();

      expect(cubit.state, isA<AudioPlaybackLoading>());
    });

    test('updateRange delegates directly to repository', () async {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 16,
      );

      await cubit.updateRange(range);
      expect(mockRepository.updateRangeCalls, equals(1));
      expect(cubit.state.range, equals(range));
    });

    test('playToAyah calls updateRange when session is active on same surah', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 2,
        currentAyah: 6,
      ));
      await pumpEventQueue();

      await cubit.playToAyah(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 20,
      );

      expect(mockRepository.updateRangeCalls, equals(1));
      expect(mockRepository.playRangeCalls, equals(0));
    });

    test('playToAyah calls playRange when session is idle', () async {
      mockRepository.emitSession(const PlaybackSession(
        status: PlaybackStatus.idle,
      ));
      await pumpEventQueue();

      await cubit.playToAyah(
        startSurah: 2,
        startAyah: 1,
        endSurah: 2,
        endAyah: 10,
      );

      expect(mockRepository.playRangeCalls, equals(1));
      expect(mockRepository.updateRangeCalls, equals(0));
    });

    test('configureRange delegates to repository configureRange and updates session range', () async {
      const range = PlaybackRange(
        startSurah: 1,
        startAyah: 1,
        endSurah: 1,
        endAyah: 7,
      );

      await cubit.configureRange(range);
      expect(mockRepository.configureRangeCalls, equals(1));
      expect(cubit.state.range, equals(range));
    });

    test('setRepeatSettings delegates to repository and updates repeatSettings', () async {
      const settings = RepeatSettings(
        repeatRange: 3,
        repeatAyah: 2,
      );

      await cubit.setRepeatSettings(settings);
      expect(mockRepository.lastRepeatSettings, equals(settings));
    });
  });
}

