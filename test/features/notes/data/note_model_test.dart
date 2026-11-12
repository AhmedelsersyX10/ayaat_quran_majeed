import 'dart:convert';
import 'package:ayaat_quran_majeed/features/notes/data/models/note_model.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteModel Serialization & Mapping Tests', () {
    final testDate = DateTime(2026, 11, 12, 10, 0, 0);

    test('round-trip serialization toMap and fromMap works correctly', () {
      final model = NoteModel(
        id: 'note_123',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
        createdAt: testDate,
        updatedAt: testDate.add(const Duration(hours: 1)),
      );

      final map = model.toMap();
      final recreated = NoteModel.fromMap(map);

      expect(recreated.id, equals(model.id));
      expect(recreated.surahNumber, equals(model.surahNumber));
      expect(recreated.verseNumber, equals(model.verseNumber));
      expect(recreated.pageNumber, equals(model.pageNumber));
      expect(recreated.noteText, equals(model.noteText));
      expect(recreated.createdAt.toIso8601String(), equals(model.createdAt.toIso8601String()));
      expect(recreated.updatedAt?.toIso8601String(), equals(model.updatedAt?.toIso8601String()));
    });

    test('round-trip JSON serialization works seamlessly', () {
      final model = NoteModel(
        id: 'note_456',
        surahNumber: 1,
        verseNumber: 1,
        pageNumber: 1,
        noteText: 'بسم الله الرحمن الرحيم تدبر',
        createdAt: testDate,
      );

      final jsonStr = model.toJson();
      final decoded = NoteModel.fromJson(jsonStr);

      expect(decoded.id, equals(model.id));
      expect(decoded.surahNumber, equals(1));
      expect(decoded.verseNumber, equals(1));
      expect(decoded.noteText, equals('بسم الله الرحمن الرحيم تدبر'));
    });

    test('tryParse handles Map and JSON strings gracefully', () {
      // Map
      final parsedFromMap = NoteModel.tryParse({
        'id': 'n_1',
        'surahNumber': 2,
        'verseNumber': 255,
        'noteText': 'آية الكرسي',
        'createdAt': testDate.toIso8601String(),
      });
      expect(parsedFromMap, isNotNull);
      expect(parsedFromMap!.surahNumber, equals(2));
      expect(parsedFromMap.verseNumber, equals(255));

      // JSON string
      final jsonPayload = json.encode({
        'id': 'n_2',
        'surah': 3,
        'ayah': 10,
        'text': 'ملاحظة',
      });
      final parsedFromJson = NoteModel.tryParse(jsonPayload);
      expect(parsedFromJson, isNotNull);
      expect(parsedFromJson!.surahNumber, equals(3));
      expect(parsedFromJson.verseNumber, equals(10));

      // Invalid / Null
      expect(NoteModel.tryParse(null), isNull);
      expect(NoteModel.tryParse('invalid string'), isNull);
      expect(NoteModel.tryParse(12345), isNull);
    });

    test('conversion between NoteModel and NoteItem preserves all data', () {
      final entity = NoteItem(
        id: 'entity_1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'خواطر وتأملات',
        createdAt: testDate,
      );

      final model = NoteModel.fromEntity(entity);
      expect(model.id, equals('entity_1'));
      expect(model.surahNumber, equals(2));
      expect(model.verseNumber, equals(4));

      final convertedBack = model.toEntity();
      expect(convertedBack.id, equals(entity.id));
      expect(convertedBack.noteText, equals(entity.noteText));
      expect(convertedBack.pageNumber, equals(2));
    });
  });
}

