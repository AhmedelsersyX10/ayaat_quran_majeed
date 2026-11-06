import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  group('QuranMetadataService Parity & Verification Tests', () {
    const service = QuranMetadataService();

    test('Total counts match standard Mushaf specification', () {
      expect(service.totalPagesCount, 604);
      expect(service.totalSurahCount, 114);
      expect(service.totalJuzCount, 30);
    });

    test('Surah metadata matches canonical values', () {
      expect(service.getSurahNameArabic(1), 'الفاتحة');
      expect(service.getSurahNameArabic(2), 'البقرة');
      expect(service.getSurahNameArabic(36), 'يس');
      expect(service.getSurahNameArabic(112), 'الإخلاص');
      expect(service.getSurahNameArabic(114), 'الناس');

      expect(service.getVerseCount(1), 7);
      expect(service.getVerseCount(2), 286);
      expect(service.getVerseCount(114), 6);
    });

    test('Page mapping matches Madani Mushaf layout across key anchors', () {
      // Al-Fatihah
      expect(service.getPageNumber(1, 1), 1);
      expect(service.getPageNumber(1, 7), 1);

      // Al-Baqarah start
      expect(service.getPageNumber(2, 1), 2);

      // Ayat Al-Kursi
      expect(service.getPageNumber(2, 255), 42);

      // Surah Yasin start
      expect(service.getPageNumber(36, 1), 440);

      // Surah An-Nas end
      expect(service.getPageNumber(114, 6), 604);
    });

    test('getPageData returns valid segment boundaries', () {
      final page1Data = service.getPageData(1);
      expect(page1Data, isNotEmpty);
      expect(page1Data.first['surah'], 1);
      expect(page1Data.first['start'], 1);
      expect(page1Data.first['end'], 7);

      final page604Data = service.getPageData(604);
      expect(page604Data.length, greaterThanOrEqualTo(3));
      final surahsOn604 = page604Data.map((e) => e['surah']).toList();
      expect(surahsOn604, containsAll([112, 113, 114]));
    });

    test('getJuzNumber correctly classifies verses across Juz boundaries', () {
      // Juz 1
      expect(service.getJuzNumber(1, 1), 1);
      expect(service.getJuzNumber(2, 141), 1);

      // Juz 2 starts at 2:142
      expect(service.getJuzNumber(2, 142), 2);

      // Juz 30
      expect(service.getJuzNumber(114, 1), 30);
    });

    test('getSurahAndVersesFromJuz returns complete surah-to-verse ranges', () {
      final juz1 = service.getSurahAndVersesFromJuz(1);
      expect(juz1.containsKey(1), isTrue);
      expect(juz1[1], [1, 7]);
      expect(juz1.containsKey(2), isTrue);
      expect(juz1[2], [1, 141]);

      final juz30 = service.getSurahAndVersesFromJuz(30);
      expect(juz30.containsKey(114), isTrue);
      expect(juz30[114], [1, 6]);
    });

    test('isMakki correctly differentiates Makki and Madani surahs', () {
      expect(service.isMakki(1), isTrue); // Al-Fatihah is Makki
      expect(service.isMakki(2), isFalse); // Al-Baqarah is Madani
      expect(service.isMakki(3), isFalse); // Al-Imran is Madani
      expect(service.isMakki(112), isTrue); // Al-Ikhlas is Makki
      expect(service.isMakki(114), isTrue); // An-Nas is Makki
    });

    test('getJuzStartPage returns accurate starting page for each Juz', () {
      expect(service.getJuzStartPage(1), 1);
      expect(service.getJuzStartPage(2), 22);
      expect(service.getJuzStartPage(3), 42);
      expect(service.getJuzStartPage(4), 62);
      expect(service.getJuzStartPage(5), 82);
      expect(service.getJuzStartPage(6), 102);
      expect(service.getJuzStartPage(30), 582);

      expect(() => service.getJuzStartPage(0), throwsArgumentError);
      expect(() => service.getJuzStartPage(31), throwsArgumentError);
    });

    test('getVerse returns non-empty Arabic text and symbols', () {
      final fatiha1 = service.getVerse(1, 1);
      expect(fatiha1, isNotEmpty);
      expect(fatiha1.contains('بِسۡمِ'), isTrue);

      final qcf = service.getVerseQCF(1, 1);
      expect(qcf, isNotEmpty);

      final endSymbol = service.getVerseEndSymbol(1, arabicNumeral: true);
      expect(endSymbol, isNotEmpty);
    });

    test('getAudioURLByVerse produces valid URLs for reciters', () {
      final url = service.getAudioURLByVerse(1, 1, 'ar.alafasy');
      expect(url, startsWith('https://cdn.islamic.network/quran/audio/'));
      expect(url, endsWith('/1.mp3'));
    });

    test('HighlightVerse model works for single and multi-line highlights', () {
      const highlight = HighlightVerse(
        verseNumber: 255,
        page: 42,
        surah: 2,
        color: Colors.amber,
      );

      expect(highlight.surah, 2);
      expect(highlight.verseNumber, 255);
      expect(highlight.page, 42);
      expect(highlight.color, Colors.amber);

      final modified = highlight.copyWith(color: Colors.blue);
      expect(modified.color, Colors.blue);
      expect(modified.surah, 2);
    });
  });
}
