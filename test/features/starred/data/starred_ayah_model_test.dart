import 'package:ayaat_quran_majeed/features/starred/data/models/starred_ayah_model.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StarredAyahModel Data Layer Tests', () {
    test('toMap and fromMap serialize and deserialize correctly', () {
      final now = DateTime(2026, 11, 12, 10, 30);
      final model = StarredAyahModel(
        surahNumber: 2,
        verseNumber: 255,
        createdAt: now,
      );

      final map = model.toMap();
      expect(map['surahNumber'], equals(2));
      expect(map['verseNumber'], equals(255));
      expect(map['createdAt'], equals(now.toIso8601String()));

      final reconstructed = StarredAyahModel.fromMap(map);
      expect(reconstructed.surahNumber, equals(2));
      expect(reconstructed.verseNumber, equals(255));
      expect(reconstructed.createdAt, equals(now));
      expect(reconstructed, equals(model));
    });

    test('tryParse parses diverse shapes successfully', () {
      // 1. Model instance
      const m = StarredAyahModel(surahNumber: 1, verseNumber: 2);
      expect(StarredAyahModel.tryParse(m), equals(m));

      // 2. Map
      final fromMap = StarredAyahModel.tryParse({'surah': 2, 'ayah': 5});
      expect(fromMap?.surahNumber, equals(2));
      expect(fromMap?.verseNumber, equals(5));

      // 3. Colon string format: "2:255"
      final fromColon = StarredAyahModel.tryParse('2:255');
      expect(fromColon?.surahNumber, equals(2));
      expect(fromColon?.verseNumber, equals(255));

      // 4. Hyphen string format: "2-255"
      final fromHyphen = StarredAyahModel.tryParse('2-255');
      expect(fromHyphen?.surahNumber, equals(2));
      expect(fromHyphen?.verseNumber, equals(255));

      // 5. JSON string
      final fromJson = StarredAyahModel.tryParse('{"surahNumber": 3, "verseNumber": 10}');
      expect(fromJson?.surahNumber, equals(3));
      expect(fromJson?.verseNumber, equals(10));

      // 6. Invalid / null / empty
      expect(StarredAyahModel.tryParse(null), isNull);
      expect(StarredAyahModel.tryParse(''), isNull);
      expect(StarredAyahModel.tryParse('invalid'), isNull);
    });

    test('fromEntity and toEntity map correctly', () {
      const entity = StarredAyahItem(
        surahNumber: 1,
        verseNumber: 2,
        pageNumber: 1,
        ayahText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        surahName: 'الفاتحة',
      );

      final model = StarredAyahModel.fromEntity(entity);
      expect(model.surahNumber, equals(1));
      expect(model.verseNumber, equals(2));

      final convertedEntity = model.toEntity();
      expect(convertedEntity.surahNumber, equals(1));
      expect(convertedEntity.verseNumber, equals(2));
      expect(convertedEntity.pageNumber, equals(1));
      expect(convertedEntity.surahName, equals('الفاتحة'));
      expect(convertedEntity.ayahText, isNotEmpty);
    });
  });
}
