import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AyahTiming Entity Tests', () {
    const timing = AyahTiming(
      ayah: 1,
      startTimeMs: 1000,
      endTimeMs: 5000,
    );

    test('containsPosition correctly evaluates position boundaries', () {
      expect(timing.containsPosition(999), isFalse);
      expect(timing.containsPosition(1000), isTrue); // Start boundary inclusive
      expect(timing.containsPosition(3000), isTrue); // Within interval
      expect(timing.containsPosition(4999), isTrue);
      expect(timing.containsPosition(5000), isFalse); // End boundary exclusive
      expect(timing.containsPosition(6000), isFalse);
    });

    test('startDuration and endDuration return expected Durations', () {
      expect(timing.startDuration, equals(const Duration(milliseconds: 1000)));
      expect(timing.endDuration, equals(const Duration(milliseconds: 5000)));
    });

    test('value equality and hashCode behave correctly', () {
      const same = AyahTiming(ayah: 1, startTimeMs: 1000, endTimeMs: 5000);
      const different = AyahTiming(ayah: 2, startTimeMs: 1000, endTimeMs: 5000);

      expect(timing, equals(same));
      expect(timing.hashCode, equals(same.hashCode));
      expect(timing, isNot(equals(different)));
    });
  });

  group('SurahTiming Entity Tests', () {
    const basmala = AyahTiming(ayah: 0, startTimeMs: 0, endTimeMs: 4000);
    const ayah1 = AyahTiming(ayah: 1, startTimeMs: 4000, endTimeMs: 10000);
    const ayah2 = AyahTiming(ayah: 2, startTimeMs: 10000, endTimeMs: 16000);

    const surahTiming = SurahTiming(
      surahNumber: 2,
      readId: 1,
      ayahTimings: [basmala, ayah1, ayah2],
    );

    test('hasTiming returns true when ayahTimings is not empty', () {
      expect(surahTiming.hasTiming, isTrue);

      const emptyTiming = SurahTiming(
        surahNumber: 2,
        readId: 1,
        ayahTimings: [],
      );
      expect(emptyTiming.hasTiming, isFalse);
    });

    test('findAyahAt returns null during Basmala (ayah: 0)', () {
      // 0 to 3999 ms is Basmala
      expect(surahTiming.findAyahAt(0), isNull);
      expect(surahTiming.findAyahAt(2000), isNull);
      expect(surahTiming.findAyahAt(3999), isNull);
    });

    test('findAyahAt returns correct ayah number during recitation', () {
      expect(surahTiming.findAyahAt(4000), equals(1));
      expect(surahTiming.findAyahAt(7500), equals(1));
      expect(surahTiming.findAyahAt(10000), equals(2));
      expect(surahTiming.findAyahAt(15999), equals(2));
    });

    test('findAyahAt returns null when position is outside all intervals', () {
      expect(surahTiming.findAyahAt(16000), isNull);
      expect(surahTiming.findAyahAt(99999), isNull);
    });

    test('findAyahAt returns null when surah has no timing entries', () {
      const emptyTiming = SurahTiming(
        surahNumber: 3,
        readId: 1,
        ayahTimings: [],
      );
      expect(emptyTiming.findAyahAt(5000), isNull);
    });

    test('value equality and hashCode match for identical lists', () {
      const same = SurahTiming(
        surahNumber: 2,
        readId: 1,
        ayahTimings: [basmala, ayah1, ayah2],
      );
      expect(surahTiming, equals(same));
      expect(surahTiming.hashCode, equals(same.hashCode));
    });
  });
}
