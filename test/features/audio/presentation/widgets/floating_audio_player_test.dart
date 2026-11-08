import 'dart:async';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/floating_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  PlaybackSession _session = const PlaybackSession(status: PlaybackStatus.idle);

  int playAyahCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;
  int? lastSeekAyah;

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _session;

  void emit(PlaybackSession s) {
    _session = s;
    _controller.add(s);
  }

  @override
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    RepeatSettings? repeatSettings,
  }) async {
    playAyahCalls++;
    emit(_session.copyWith(
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
  }) async {}

  @override
  Future<void> playRange({
    required PlaybackRange range,
    RepeatSettings? repeatSettings,
  }) async {}

  @override
  Future<void> updateRange(PlaybackRange range) async {
    emit(_session.copyWith(range: range));
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    emit(_session.copyWith(status: PlaybackStatus.paused));
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
    emit(_session.copyWith(status: PlaybackStatus.playing));
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    emit(const PlaybackSession(status: PlaybackStatus.idle));
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> seekToAyah(int ayahNumber) async {
    lastSeekAyah = ayahNumber;
    emit(_session.copyWith(currentAyah: () => ayahNumber));
  }

  @override
  Future<void> setRepeatSettings(RepeatSettings settings) async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late FakePlaybackRepository repository;
  late AudioPlaybackCubit cubit;

  const testReciter = Reciter(
    id: 1,
    name: 'محمود خليل الحصري',
    letter: 'م',
    moshafs: [
      Moshaf(
        id: 118,
        name: 'حفص عن عاصم - مرتل',
        server: 'https://cdn.mp3quran.net/',
        surahTotal: 114,
        moshafType: 1,
        surahList: [1],
      ),
    ],
  );

  setUp(() {
    repository = FakePlaybackRepository();
    cubit = AudioPlaybackCubit(playbackRepository: repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  Widget buildTestableWidget({
    VoidCallback? onSettings,
    VoidCallback? onDismiss,
    VoidCallback? onPlayFallback,
    bool isInitiallyExpanded = false,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: BlocProvider<AudioPlaybackCubit>.value(
            value: cubit,
            child: Center(
              child: FloatingAudioPlayer(
                onSettingsPressed: onSettings,
                onDismiss: onDismiss,
                onPlayFallback: onPlayFallback,
                isInitiallyExpanded: isInitiallyExpanded,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('FloatingAudioPlayer Widget Tests', () {
    testWidgets('renders compact pill matching Reference 05 when idle', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Reciter name and chevron
      expect(find.text('محمود خليل الحصري'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      // Play button
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('tapping play in compact idle mode invokes fallback callback', (tester) async {
      bool playFallbackCalled = false;
      await tester.pumpWidget(buildTestableWidget(
        onPlayFallback: () => playFallbackCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(playFallbackCalled, isTrue);
    });

    testWidgets('renders expanded loading state matching Video 37 (00:00)', (tester) async {
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.loading,
        surahNumber: 1,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Should display "جاري التحميل" in loading state
      expect(find.text(AppStrings.tr(AppStrings.loadingAudio)), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('renders expanded playing state matching Video 37 (00:01)', (tester) async {
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 2,
        hasTiming: true,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Equalizer bars, Pause button, Skip Previous & Next
      expect(find.byType(EqualizerWaveBars), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('tapping pause button calls pause() on cubit', (tester) async {
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 2,
        hasTiming: true,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();

      expect(repository.pauseCalls, equals(1));
    });

    testWidgets('tapping play button in paused state calls resume() on cubit', (tester) async {
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.paused,
        surahNumber: 1,
        currentAyah: 3,
        hasTiming: true,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget(isInitiallyExpanded: true));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      expect(repository.resumeCalls, equals(1));
    });

    testWidgets('tapping skip buttons invokes skipNextAyah and skipPreviousAyah', (tester) async {
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 3,
        hasTiming: true,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget(isInitiallyExpanded: true));
      await tester.pump();

      // Tap Next Ayah (skip_previous in RTL)
      await tester.tap(find.byIcon(Icons.skip_previous_rounded));
      await tester.pump();
      expect(repository.lastSeekAyah, equals(4));

      // Tap Previous Ayah (skip_next in RTL)
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();
      expect(repository.lastSeekAyah, equals(3));
    });

    testWidgets('tapping close [x] stops playback and triggers onDismiss', (tester) async {
      bool dismissed = false;
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 1,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget(
        onDismiss: () => dismissed = true,
        isInitiallyExpanded: true,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(repository.stopCalls, equals(1));
      expect(dismissed, isTrue);
    });

    testWidgets('tapping [...] triggers onSettingsPressed', (tester) async {
      bool settingsPressed = false;
      repository.emit(const PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        reciter: testReciter,
      ));

      await tester.pumpWidget(buildTestableWidget(
        onSettings: () => settingsPressed = true,
        isInitiallyExpanded: true,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pump();

      expect(settingsPressed, isTrue);
    });
  });
}
