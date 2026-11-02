import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranSearchRepository Tests', () {
    late QuranSearchRepository repository;

    setUp(() {
      repository = QuranSearchRepository(
        metadataService: const QuranMetadataService(),
      );
    });

    test('Empty query returns empty list', () async {
      final results = await repository.search('');
      expect(results, isEmpty);

      final whitespaceResults = await repository.search('   ');
      expect(whitespaceResults, isEmpty);
    });

    test('Search finds exact word in Al-Fatihah', () async {
      final results = await repository.search('الحمد');
      expect(results, isNotEmpty);
      final firstMatch = results.firstWhere(
        (r) => r.surahNumber == 1 && r.verseNumber == 2,
      );
      expect(firstMatch.surahName, 'الفاتحة');
      expect(firstMatch.pageNumber, 1);
      expect(
        QuranSearchRepository.normalizeArabicText(firstMatch.originalText),
        contains('الحمد'),
      );
    });

    test('Search normalizes Alif variants and matches', () async {
      final resultsWithBareAlif = await repository.search('الله');
      expect(resultsWithBareAlif, isNotEmpty);

      final resultsWithHamza = await repository.search('أحد');
      expect(resultsWithHamza, isNotEmpty);
      final ikhlasMatch = resultsWithHamza.any(
        (r) => r.surahNumber == 112 && r.verseNumber == 1,
      );
      expect(ikhlasMatch, isTrue);
    });
  });
}
