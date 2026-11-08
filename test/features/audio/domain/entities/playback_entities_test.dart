import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepeatSettings Entity Tests', () {
    test('default constructor sets all counters to 1', () {
      const settings = RepeatSettings();
      expect(settings.repeatAyah, 1);
      expect(settings.repeatRange, 1);
      expect(settings.currentAyahRepeat, 1);
      expect(settings.currentRangeRepeat, 1);
      expect(settings.isAyahRepeatComplete, isTrue);
      expect(settings.isRangeRepeatComplete, isTrue);
    });

    test('repetition completion getters work accurately', () {
      const settings = RepeatSettings(
        repeatAyah: 3,
        repeatRange: 2,
        currentAyahRepeat: 2,
        currentRangeRepeat: 1,
      );
      expect(settings.isAyahRepeatComplete, isFalse);
      expect(settings.isRangeRepeatComplete, isFalse);

      final next = settings.copyWith(currentAyahRepeat: 3);
      expect(next.isAyahRepeatComplete, isTrue);
      expect(next.isRangeRepeatComplete, isFalse);

      final finished = next.copyWith(currentRangeRepeat: 2);
      expect(finished.isRangeRepeatComplete, isTrue);
    });

    test('equality and toString behave correctly', () {
      const a = RepeatSettings(repeatAyah: 2, repeatRange: 3);
      const b = RepeatSettings(repeatAyah: 2, repeatRange: 3);
      const c = RepeatSettings(repeatAyah: 1, repeatRange: 3);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('ayah: 1/2'));
    });
  });

  group('PlaybackRange Entity Tests', () {
    test('singleAyah factory creates identical start and end', () {
      final range = PlaybackRange.singleAyah(2, 255);
      expect(range.startSurah, 2);
      expect(range.startAyah, 255);
      expect(range.endSurah, 2);
      expect(range.endAyah, 255);
      expect(range.isSingleAyah, isTrue);
      expect(range.isSingleSurah, isTrue);
    });

    test('surah factory creates range from startAyah to totalAyat', () {
      final range = PlaybackRange.surah(1, 7, startAyah: 3);
      expect(range.startSurah, 1);
      expect(range.startAyah, 3);
      expect(range.endSurah, 1);
      expect(range.endAyah, 7);
      expect(range.isSingleAyah, isFalse);
      expect(range.isSingleSurah, isTrue);
    });

    test('contains accurately tests verses within and outside range', () {
      // Range: Al-Baqarah 250 -> Aal-Imran 10
      final range = PlaybackRange.custom(
        startSurah: 2,
        startAyah: 250,
        endSurah: 3,
        endAyah: 10,
      );

      // Outside before start surah
      expect(range.contains(1, 1), isFalse);
      // Outside before start ayah
      expect(range.contains(2, 249), isFalse);
      // Boundary start
      expect(range.contains(2, 250), isTrue);
      expect(range.contains(2, 286), isTrue);
      // Boundary inside end surah
      expect(range.contains(3, 1), isTrue);
      expect(range.contains(3, 10), isTrue);
      // Outside after end ayah
      expect(range.contains(3, 11), isFalse);
      // Outside after end surah
      expect(range.contains(4, 1), isFalse);
    });

    test('isLastAyah detects boundary verse correctly', () {
      final range = PlaybackRange.custom(
        startSurah: 2,
        startAyah: 1,
        endSurah: 2,
        endAyah: 5,
      );

      expect(range.isLastAyah(2, 4), isFalse);
      expect(range.isLastAyah(2, 5), isTrue);
      expect(range.isLastAyah(1, 5), isFalse);
    });
  });

  group('PlaybackSession Entity Tests', () {
    const testMoshaf = Moshaf(
      id: 1,
      name: 'حفص عن عاصم',
      server: 'https://server.test/',
      surahTotal: 114,
      moshafType: 1,
      hasTiming: true,
      surahList: [1, 2, 3],
    );

    const testReciter = Reciter(
      id: 10,
      name: 'مشاري العفاسي',
      letter: 'م',
      moshafs: [testMoshaf],
    );

    test('initial factory sets idle state and optional reciter/moshaf', () {
      final session = PlaybackSession.initial(
        reciter: testReciter,
        moshaf: testMoshaf,
      );

      expect(session.status, PlaybackStatus.idle);
      expect(session.reciter, equals(testReciter));
      expect(session.moshaf, equals(testMoshaf));
      expect(session.currentAyah, isNull);
      expect(session.isActive, isFalse);
      expect(session.isPlaying, isFalse);
      expect(session.isPaused, isFalse);
    });

    test('copyWith updates state and active flags correctly', () {
      final initial = PlaybackSession.initial(reciter: testReciter);
      final playing = initial.copyWith(
        status: PlaybackStatus.playing,
        surahNumber: 2,
        currentAyah: () => 5,
        position: const Duration(seconds: 15),
        duration: const Duration(minutes: 5),
        hasTiming: true,
      );

      expect(playing.status, PlaybackStatus.playing);
      expect(playing.surahNumber, 2);
      expect(playing.currentAyah, 5);
      expect(playing.position.inSeconds, 15);
      expect(playing.hasTiming, isTrue);
      expect(playing.isActive, isTrue);
      expect(playing.isPlaying, isTrue);
      expect(playing.isPaused, isFalse);

      final paused = playing.copyWith(status: PlaybackStatus.paused);
      expect(paused.isActive, isTrue);
      expect(paused.isPlaying, isFalse);
      expect(paused.isPaused, isTrue);
    });
  });
}

