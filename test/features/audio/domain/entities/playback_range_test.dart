import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRange Entity & Domain Semantics Tests', () {
    test('isValidRange validates inclusive boundaries and end-before-start', () {
      // Valid cases
      expect(PlaybackRange.isValidRange(1, 1, 1, 7), isTrue);
      expect(PlaybackRange.isValidRange(2, 6, 2, 10), isTrue);
      expect(PlaybackRange.isValidRange(2, 6, 2, 6), isTrue); // single ayah
      expect(PlaybackRange.isValidRange(2, 280, 3, 10), isTrue); // multi-surah
      expect(PlaybackRange.isValidRange(1, 1, 114, 6), isTrue); // whole Quran

      // Invalid: end before start (same surah)
      expect(PlaybackRange.isValidRange(2, 10, 2, 5), isFalse);

      // Invalid: end before start (endSurah < startSurah)
      expect(PlaybackRange.isValidRange(3, 1, 2, 286), isFalse);

      // Invalid: out-of-bounds surah numbers
      expect(PlaybackRange.isValidRange(0, 1, 1, 5), isFalse);
      expect(PlaybackRange.isValidRange(1, 1, 115, 1), isFalse);

      // Invalid: out-of-bounds verse numbers
      expect(PlaybackRange.isValidRange(1, 0, 1, 5), isFalse);
      expect(PlaybackRange.isValidRange(1, 1, 1, 0), isFalse);
    });

    test('constructor asserts end is not before start', () {
      expect(
        () => PlaybackRange(
          startSurah: 2,
          startAyah: 10,
          endSurah: 2,
          endAyah: 5,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => PlaybackRange(
          startSurah: 3,
          startAyah: 1,
          endSurah: 2,
          endAyah: 10,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('PlaybackRange.validated throws ArgumentError for invalid range', () {
      expect(
        () => PlaybackRange.validated(
          startSurah: 2,
          startAyah: 20,
          endSurah: 2,
          endAyah: 10,
        ),
        throwsA(isA<ArgumentError>()),
      );

      final valid = PlaybackRange.validated(
        startSurah: 2,
        startAyah: 1,
        endSurah: 2,
        endAyah: 10,
      );
      expect(valid.startAyah, 1);
      expect(valid.endAyah, 10);
    });

    test('contains enforces inclusive boundaries within single surah', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 10,
      );

      // Inclusive start and end
      expect(range.contains(2, 6), isTrue);
      expect(range.contains(2, 10), isTrue);

      // Interior verses
      expect(range.contains(2, 7), isTrue);
      expect(range.contains(2, 8), isTrue);
      expect(range.contains(2, 9), isTrue);

      // Outside boundaries
      expect(range.contains(2, 5), isFalse);
      expect(range.contains(2, 11), isFalse);
      expect(range.contains(1, 6), isFalse);
      expect(range.contains(3, 6), isFalse);
    });

    test('contains enforces inclusive boundaries across multiple surahs', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 280,
        endSurah: 3,
        endAyah: 15,
      );

      // In start surah
      expect(range.contains(2, 279), isFalse);
      expect(range.contains(2, 280), isTrue); // inclusive start
      expect(range.contains(2, 286), isTrue);

      // In end surah
      expect(range.contains(3, 1), isTrue);
      expect(range.contains(3, 15), isTrue); // inclusive end
      expect(range.contains(3, 16), isFalse);

      // Outside range
      expect(range.contains(1, 1), isFalse);
      expect(range.contains(4, 1), isFalse);
    });

    test('isStart, isLastAyah and isEnd identify range endpoints accurately', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 10,
      );

      expect(range.isStart(2, 6), isTrue);
      expect(range.isStart(2, 7), isFalse);

      expect(range.isLastAyah(2, 10), isTrue);
      expect(range.isEnd(2, 10), isTrue);
      expect(range.isLastAyah(2, 9), isFalse);
    });

    test('isBeforeStart and isPastEnd correctly detect position relative to range', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 10,
      );

      expect(range.isBeforeStart(1, 5), isTrue);
      expect(range.isBeforeStart(2, 5), isTrue);
      expect(range.isBeforeStart(2, 6), isFalse);
      expect(range.isBeforeStart(2, 8), isFalse);

      expect(range.isPastEnd(2, 10), isFalse);
      expect(range.isPastEnd(2, 11), isTrue);
      expect(range.isPastEnd(3, 1), isTrue);
    });

    test('copyWithNewEnd updates endpoint with validation', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 6,
        endSurah: 2,
        endAyah: 10,
      );

      final updated = range.copyWithNewEnd(endSurah: 2, endAyah: 20);
      expect(updated.startSurah, 2);
      expect(updated.startAyah, 6);
      expect(updated.endSurah, 2);
      expect(updated.endAyah, 20);

      // Attempting to set end before start throws
      expect(
        () => range.copyWithNewEnd(endSurah: 2, endAyah: 4),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('withCurrentPositionAsStart adjusts start position forward', () {
      const range = PlaybackRange(
        startSurah: 2,
        startAyah: 1,
        endSurah: 2,
        endAyah: 50,
      );

      final shifted = range.withCurrentPositionAsStart(
        currentSurah: 2,
        currentAyah: 15,
      );
      expect(shifted.startSurah, 2);
      expect(shifted.startAyah, 15);
      expect(shifted.endSurah, 2);
      expect(shifted.endAyah, 50);
    });

    test('preset factories construct expected ranges', () {
      // Page preset
      final pageRange = PlaybackRange.page(
        startSurah: 2,
        startAyah: 6,
        lastSurahOnPage: 2,
        lastAyahOnPage: 16,
      );
      expect(pageRange.startSurah, 2);
      expect(pageRange.startAyah, 6);
      expect(pageRange.endSurah, 2);
      expect(pageRange.endAyah, 16);

      // Surah preset
      final surahRange = PlaybackRange.endOfSurah(
        startSurah: 2,
        startAyah: 6,
        totalAyatInSurah: 286,
      );
      expect(surahRange.startSurah, 2);
      expect(surahRange.startAyah, 6);
      expect(surahRange.endSurah, 2);
      expect(surahRange.endAyah, 286);

      // Continuous preset (stops at Quran end 114:6)
      final continuousRange = PlaybackRange.continuous(
        startSurah: 2,
        startAyah: 6,
      );
      expect(continuousRange.startSurah, 2);
      expect(continuousRange.startAyah, 6);
      expect(continuousRange.endSurah, 114);
      expect(continuousRange.endAyah, 6);
    });
  });
}

