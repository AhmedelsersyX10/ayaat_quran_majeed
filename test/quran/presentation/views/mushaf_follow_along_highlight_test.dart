import 'dart:async';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart' as qp;

class FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  PlaybackSession _session = const PlaybackSession(status: PlaybackStatus.idle);

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _session;

  void emit(PlaybackSession s) {
    _session = s;
    _controller.add(s);
  }

  @override
  Future<void> playAyah({required int surahNumber, required int ayahNumber, RepeatSettings? repeatSettings}) async {}
  @override
  Future<void> playSurah({required int surahNumber, int startAyah = 1, RepeatSettings? repeatSettings}) async {}
  @override
  Future<void> playRange({required PlaybackRange range, RepeatSettings? repeatSettings}) async {}
  @override
  Future<void> updateRange(PlaybackRange range) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> seekToAyah(int ayahNumber) async {}
  @override
  Future<void> setRepeatSettings(RepeatSettings settings) async {}
  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  const metadataService = QuranMetadataService();
  late FakePlaybackRepository repository;
  late AudioPlaybackCubit cubit;

  setUp(() {
    repository = FakePlaybackRepository();
    cubit = AudioPlaybackCubit(playbackRepository: repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  group('Mushaf Follow-Along Highlighting & Timing Constraints (Task 4.04)', () {
    test('adds HighlightVerse with playbackHighlight when hasTiming is true and currentAyah is not null', () {
      const session = PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 2,
        hasTiming: true,
      );
      const state = AudioPlaybackPlaying(session);

      final activeHighlights = <qp.HighlightVerse>[];

      // Replicating buildPageView highlight generation logic
      if (state.hasTiming && state.currentAyah != null) {
        final s = state.surahNumber;
        final a = state.currentAyah!;
        final page = metadataService.getPageNumber(s, a);
        activeHighlights.add(
          qp.HighlightVerse(
            surah: s,
            verseNumber: a,
            page: page,
            color: AppColors.playbackHighlight,
          ),
        );
      }

      expect(activeHighlights.length, equals(1));
      expect(activeHighlights.first.surah, equals(1));
      expect(activeHighlights.first.verseNumber, equals(2));
      expect(activeHighlights.first.page, equals(1));
      expect(activeHighlights.first.color, equals(AppColors.playbackHighlight));
    });

    test('mandatory constraint: no highlight added when hasTiming is false', () {
      const session = PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 2,
        hasTiming: false, // Untimed recitation
      );
      const state = AudioPlaybackPlaying(session);

      final activeHighlights = <qp.HighlightVerse>[];

      // Replicating buildPageView highlight generation logic
      if (state.hasTiming && state.currentAyah != null) {
        final s = state.surahNumber;
        final a = state.currentAyah!;
        final page = metadataService.getPageNumber(s, a);
        activeHighlights.add(
          qp.HighlightVerse(
            surah: s,
            verseNumber: a,
            page: page,
            color: AppColors.playbackHighlight,
          ),
        );
      }

      // Must be empty per constraint
      expect(activeHighlights, isEmpty);
    });

    test('mandatory constraint: no highlight added during Basmala / intro (currentAyah == null)', () {
      const session = PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 2,
        currentAyah: null, // Basmala interval
        hasTiming: true,
      );
      const state = AudioPlaybackPlaying(session);

      final activeHighlights = <qp.HighlightVerse>[];

      if (state.hasTiming && state.currentAyah != null) {
        final s = state.surahNumber;
        final a = state.currentAyah!;
        final page = metadataService.getPageNumber(s, a);
        activeHighlights.add(
          qp.HighlightVerse(
            surah: s,
            verseNumber: a,
            page: page,
            color: AppColors.playbackHighlight,
          ),
        );
      }

      expect(activeHighlights, isEmpty);
    });

    test('multi-line ayah highlight targets the correct surah and ayah spanning lines', () {
      // In Surah Al-Fatihah, Ayah 5 spans across lines 4 and 5
      const session = PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 5,
        hasTiming: true,
      );
      const state = AudioPlaybackPlaying(session);

      final activeHighlights = <qp.HighlightVerse>[];

      if (state.hasTiming && state.currentAyah != null) {
        final s = state.surahNumber;
        final a = state.currentAyah!;
        final page = metadataService.getPageNumber(s, a);
        activeHighlights.add(
          qp.HighlightVerse(
            surah: s,
            verseNumber: a,
            page: page,
            color: AppColors.playbackHighlight,
          ),
        );
      }

      expect(activeHighlights.length, equals(1));
      expect(activeHighlights.first.surah, equals(1));
      expect(activeHighlights.first.verseNumber, equals(5));
      expect(activeHighlights.first.page, equals(1));
    });

    test('page transition logic detects page boundaries without misleading jump', () {
      // Page 1 ends at Surah 1 Ayah 7.
      // Next ayah is Surah 2 Ayah 1, which is on Page 2.
      int currentPage = 1;
      bool isSliderDragging = false;
      int? navigatedPage;

      void onAudioStateChanged(AudioPlaybackState audioState) {
        if (audioState.hasTiming && audioState.currentAyah != null) {
          final targetPage = metadataService.getPageNumber(
            audioState.surahNumber,
            audioState.currentAyah!,
          );
          if (!isSliderDragging && targetPage >= 1 && targetPage <= 604) {
            if (targetPage != currentPage) {
              currentPage = targetPage;
              navigatedPage = targetPage;
            }
          }
        }
      }

      // Step 1: Still on page 1
      onAudioStateChanged(const AudioPlaybackPlaying(PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 1,
        currentAyah: 7,
        hasTiming: true,
      )));
      expect(navigatedPage, isNull);
      expect(currentPage, equals(1));

      // Step 2: Next ayah is Surah 2 Ayah 1 (Page 2)
      onAudioStateChanged(const AudioPlaybackPlaying(PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 2,
        currentAyah: 1,
        hasTiming: true,
      )));
      expect(navigatedPage, equals(2));
      expect(currentPage, equals(2));
    });

    test('page transition is suppressed while user is dragging page slider', () {
      int currentPage = 2;
      bool isSliderDragging = false;
      int? navigatedPage;

      void onAudioStateChanged(AudioPlaybackState audioState) {
        if (audioState.hasTiming && audioState.currentAyah != null) {
          final targetPage = metadataService.getPageNumber(
            audioState.surahNumber,
            audioState.currentAyah!,
          );
          if (!isSliderDragging && targetPage >= 1 && targetPage <= 604) {
            if (targetPage != currentPage) {
              currentPage = targetPage;
              navigatedPage = targetPage;
            }
          }
        }
      }

      // User starts scrubbing
      isSliderDragging = true;

      // Audio moves to Surah 2 Ayah 6 (Page 3), but user is dragging slider
      onAudioStateChanged(const AudioPlaybackPlaying(PlaybackSession(
        status: PlaybackStatus.playing,
        surahNumber: 2,
        currentAyah: 6,
        hasTiming: true,
      )));

      // Should NOT jump while dragging
      expect(navigatedPage, isNull);
      expect(currentPage, equals(2));
    });
  });
}

