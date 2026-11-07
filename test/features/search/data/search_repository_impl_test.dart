import 'package:ayaat_quran_majeed/features/search/data/repositories/search_repository_impl.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchRepositoryImpl Tests', () {
    late SearchRepositoryImpl repository;

    setUp(() {
      repository = SearchRepositoryImpl(
        metadataService: const QuranMetadataService(),
      );
    });

    test('Empty and whitespace queries return empty results', () async {
      final res1 = await repository.search('');
      expect(res1.isEmpty, isTrue);
      expect(res1.verses, isEmpty);
      expect(res1.pageResult, isNull);

      final res2 = await repository.search('   ');
      expect(res2.isEmpty, isTrue);
      expect(res2.verses, isEmpty);
      expect(res2.pageResult, isNull);
    });

    test('Search finds exact word in Al-Fatihah without diacritics', () async {
      final res = await repository.search('الحمد');
      expect(res.verses, isNotEmpty);
      final firstMatch = res.verses.firstWhere(
        (v) => v.surahNumber == 1 && v.verseNumber == 2,
      );
      expect(firstMatch.surahName, 'الفاتحة');
      expect(firstMatch.pageNumber, 1);
      expect(
        SearchRepositoryImpl.normalizeArabicText(firstMatch.originalText),
        contains('الحمد'),
      );
    });

    test('Search handles Arabic diacritics (tashkeel) in query', () async {
      final resWithDiacritics = await repository.search('الْحَمْدُ');
      expect(resWithDiacritics.verses, isNotEmpty);
      final firstMatch = resWithDiacritics.verses.firstWhere(
        (v) => v.surahNumber == 1 && v.verseNumber == 2,
      );
      expect(firstMatch.surahName, 'الفاتحة');
    });

    test('Search normalizes Alif variants and matches', () async {
      final resWithHamza = await repository.search('أحد');
      expect(resWithHamza.verses, isNotEmpty);
      final ikhlasMatch = resWithHamza.verses.any(
        (v) => v.surahNumber == 112 && v.verseNumber == 1,
      );
      expect(ikhlasMatch, isTrue);

      final resBareAlif = await repository.search('احد');
      expect(resBareAlif.verses, isNotEmpty);
      final ikhlasMatchBare = resBareAlif.verses.any(
        (v) => v.surahNumber == 112 && v.verseNumber == 1,
      );
      expect(ikhlasMatchBare, isTrue);
    });

    test('Search by page number with Western digits (20)', () async {
      final res = await repository.search('20');
      expect(res.pageResult, isNotNull);
      expect(res.pageResult!.pageNumber, 20);
      expect(res.pageResult!.surahNumber, 2);
      expect(res.pageResult!.surahName, 'البقرة');
      expect(res.pageResult!.verseNumber, 127);
    });

    test('Search by page number with Eastern Arabic-Indic digits (۲۰)', () async {
      final res = await repository.search('۲۰');
      expect(res.pageResult, isNotNull);
      expect(res.pageResult!.pageNumber, 20);
      expect(res.pageResult!.surahName, 'البقرة');
    });

    test('Page bounds validation for page search', () async {
      // Lower bound 1
      final res1 = await repository.search('1');
      expect(res1.pageResult, isNotNull);
      expect(res1.pageResult!.pageNumber, 1);
      expect(res1.pageResult!.surahName, 'الفاتحة');

      // Upper bound 604
      final res604 = await repository.search('604');
      expect(res604.pageResult, isNotNull);
      expect(res604.pageResult!.pageNumber, 604);
      expect(res604.pageResult!.surahName, 'الإخلاص');

      // Out of bounds: 0
      final res0 = await repository.search('0');
      expect(res0.pageResult, isNull);

      // Out of bounds: 605
      final res605 = await repository.search('605');
      expect(res605.pageResult, isNull);

      // Out of bounds: 999
      final res999 = await repository.search('999');
      expect(res999.pageResult, isNull);
    });

    test('Multi-word Boolean AND search', () async {
      final res = await repository.search('تلك أمة');
      expect(res.verses, isNotEmpty);
      for (final v in res.verses) {
        final normalized = SearchRepositoryImpl.normalizeArabicText(v.originalText);
        expect(normalized, contains('تلك'));
        expect(normalized, contains('امه'));
      }
    });

    test('Result ordering: higher score first, then surah order, then ayah order', () async {
      final res = await repository.search('تلك');
      expect(res.verses.length, greaterThan(1));

      for (int i = 0; i < res.verses.length - 1; i++) {
        final current = res.verses[i];
        final next = res.verses[i + 1];

        if (current.score != next.score) {
          expect(current.score, greaterThanOrEqualTo(next.score));
        } else if (current.surahNumber != next.surahNumber) {
          expect(current.surahNumber, lessThanOrEqualTo(next.surahNumber));
        } else {
          expect(current.verseNumber, lessThanOrEqualTo(next.verseNumber));
        }
      }
    });
  });
}
