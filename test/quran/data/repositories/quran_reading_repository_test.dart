import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranReadingRepository & ReadingPosition Validation Tests', () {
    const metadataService = QuranMetadataService();
    const repository = QuranReadingRepository(metadataService: metadataService);

    test('ReadingPosition copyWith, equality, toMap and fromMap work cleanly', () {
      const pos1 = ReadingPosition(
        page: 10,
        surahNumber: 2,
        ayahNumber: 62,
        viewMode: 'pageview',
      );
      final pos2 = pos1.copyWith(ayahNumber: 63);

      expect(pos1.ayahNumber, 62);
      expect(pos2.ayahNumber, 63);
      expect(pos1 == pos2, isFalse);

      final map = pos1.toMap();
      final fromMap = ReadingPosition.fromMap(map);
      expect(fromMap, equals(pos1));
    });

    test('validateAndNormalize clamps page < 1 to page 1 and maps to Al-Fatiha', () {
      const invalid = ReadingPosition(
        page: -5,
        surahNumber: 999,
        ayahNumber: 0,
      );

      final normalized = repository.validateAndNormalize(invalid);
      expect(normalized.page, 1);
      expect(normalized.surahNumber, 1);
      expect(normalized.ayahNumber, 1);
    });

    test('validateAndNormalize clamps page > 604 to page 604', () {
      const invalid = ReadingPosition(
        page: 700,
        surahNumber: 1,
        ayahNumber: 1,
      );

      final normalized = repository.validateAndNormalize(invalid);
      expect(normalized.page, 604);
      // Page 604 contains Surah 112, 113, 114
      expect(normalized.surahNumber, 112);
      expect(normalized.ayahNumber, 1);
    });

    test('validateAndNormalize preserves valid page and matching surah/ayah', () {
      // Page 42 contains Ayat Al-Kursi (2:255)
      const valid = ReadingPosition(
        page: 42,
        surahNumber: 2,
        ayahNumber: 255,
      );

      final normalized = repository.validateAndNormalize(valid);
      expect(normalized.page, 42);
      expect(normalized.surahNumber, 2);
      expect(normalized.ayahNumber, 255);
    });

    test('validateAndNormalize fixes stale surah/ayah that does not belong to page', () {
      // Page 10 is in Surah Al-Baqarah (verses 62-69)
      // If position has page 10 but Surah 114 (An-Nas), it must re-sync to first verse of page 10
      const mismatched = ReadingPosition(
        page: 10,
        surahNumber: 114,
        ayahNumber: 1,
      );

      final normalized = repository.validateAndNormalize(mismatched);
      expect(normalized.page, 10);
      expect(normalized.surahNumber, 2);
      expect(normalized.ayahNumber, 62);
    });

    test('ReadingPosition.fromJson handles corrupt numeric strings gracefully', () {
      final fromMap = ReadingPosition.fromMap({
        'page': null,
        'surahNumber': null,
        'ayahNumber': null,
      });

      expect(fromMap.page, 1);
      expect(fromMap.surahNumber, 1);
      expect(fromMap.ayahNumber, 1);
    });
  });
}

