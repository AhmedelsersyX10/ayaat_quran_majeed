import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Moshaf Entity Tests', () {
    const moshafWithSlash = Moshaf(
      id: 1,
      name: 'حفص عن عاصم - مرتل',
      server: 'https://cdn.mp3quran.net/audio/akdr/r1/',
      surahTotal: 114,
      moshafType: 11,
      surahList: [1, 2, 3, 114],
      hasTiming: true,
    );

    const moshafWithoutSlash = Moshaf(
      id: 2,
      name: 'ورش عن نافع',
      server: 'https://cdn.mp3quran.net/audio/warsh',
      surahTotal: 114,
      moshafType: 1,
      surahList: [1, 2],
      hasTiming: false,
    );

    test('getSurahAudioUrl builds padded 3-digit surah URL correctly', () {
      expect(
        moshafWithSlash.getSurahAudioUrl(1),
        equals('https://cdn.mp3quran.net/audio/akdr/r1/001.mp3'),
      );
      expect(
        moshafWithSlash.getSurahAudioUrl(18),
        equals('https://cdn.mp3quran.net/audio/akdr/r1/018.mp3'),
      );
      expect(
        moshafWithSlash.getSurahAudioUrl(114),
        equals('https://cdn.mp3quran.net/audio/akdr/r1/114.mp3'),
      );
    });

    test('getSurahAudioUrl handles server string without trailing slash', () {
      expect(
        moshafWithoutSlash.getSurahAudioUrl(1),
        equals('https://cdn.mp3quran.net/audio/warsh/001.mp3'),
      );
    });

    test('hasSurah checks surah availability in surahList', () {
      expect(moshafWithSlash.hasSurah(1), isTrue);
      expect(moshafWithSlash.hasSurah(114), isTrue);
      expect(moshafWithSlash.hasSurah(5), isFalse);
    });
  });

  group('Reciter Entity Tests', () {
    const moshafNoTiming = Moshaf(
      id: 10,
      name: 'قالون',
      server: 'https://server.com/',
      surahTotal: 114,
      moshafType: 1,
      surahList: [1],
      hasTiming: false,
    );

    const moshafWithTiming = Moshaf(
      id: 20,
      name: 'حفص',
      server: 'https://server.com/',
      surahTotal: 114,
      moshafType: 11,
      surahList: [1],
      hasTiming: true,
    );

    test('hasAnyTimingSupport is true when any moshaf has timing', () {
      const reciter = Reciter(
        id: 1,
        name: 'القارئ',
        letter: 'ق',
        moshafs: [moshafNoTiming, moshafWithTiming],
      );
      expect(reciter.hasAnyTimingSupport, isTrue);

      const reciterNoTiming = Reciter(
        id: 2,
        name: 'قارئ آخر',
        letter: 'ق',
        moshafs: [moshafNoTiming],
      );
      expect(reciterNoTiming.hasAnyTimingSupport, isFalse);
    });

    test('defaultMoshaf prioritizes timing-supported edition', () {
      const reciter = Reciter(
        id: 1,
        name: 'القارئ',
        letter: 'ق',
        moshafs: [moshafNoTiming, moshafWithTiming],
      );
      expect(reciter.defaultMoshaf, equals(moshafWithTiming));
    });

    test('defaultMoshaf falls back to first moshaf if none have timing', () {
      const reciter = Reciter(
        id: 1,
        name: 'القارئ',
        letter: 'ق',
        moshafs: [moshafNoTiming],
      );
      expect(reciter.defaultMoshaf, equals(moshafNoTiming));
    });

    test('defaultMoshaf returns null when moshafs list is empty', () {
      const reciter = Reciter(
        id: 1,
        name: 'القارئ',
        letter: 'ق',
        moshafs: [],
      );
      expect(reciter.defaultMoshaf, isNull);
    });
  });

  group('ReciterSurah Entity Tests', () {
    test('playableUri returns local file path when downloaded', () {
      const downloadedSurah = ReciterSurah(
        surahNumber: 1,
        surahName: 'الفاتحة',
        juzNumber: 1,
        verseCount: 7,
        audioUrl: 'https://server.com/001.mp3',
        isDownloaded: true,
        localFilePath: '/data/user/0/quran_audio/1/001.mp3',
        hasTiming: true,
      );
      expect(downloadedSurah.playableUri, equals('/data/user/0/quran_audio/1/001.mp3'));
    });

    test('playableUri returns remote audioUrl when not downloaded', () {
      const remoteSurah = ReciterSurah(
        surahNumber: 1,
        surahName: 'الفاتحة',
        juzNumber: 1,
        verseCount: 7,
        audioUrl: 'https://server.com/001.mp3',
        isDownloaded: false,
        localFilePath: null,
        hasTiming: true,
      );
      expect(remoteSurah.playableUri, equals('https://server.com/001.mp3'));
    });
  });
}
