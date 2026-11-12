import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteItem Entity Tests', () {
    final date = DateTime(2026, 11, 12, 10, 0);

    test('ayahKey returns canonical "surah:verse" format', () {
      final item = NoteItem(
        id: 'note_1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
        createdAt: date,
      );

      expect(item.ayahKey, equals('2:4'));
    });

    test('equality and hashCode evaluate properly based on id and properties', () {
      final item1 = NoteItem(
        id: 'note_1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
        createdAt: date,
      );
      final item2 = NoteItem(
        id: 'note_1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
        createdAt: date,
      );
      final item3 = NoteItem(
        id: 'note_2',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'ملاحظة أخرى',
        createdAt: date,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
      expect(item1, isNot(equals(item3)));
    });

    test('copyWith creates modified copies correctly', () {
      final original = NoteItem(
        id: 'note_1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'نص قديم',
        createdAt: date,
      );

      final updatedDate = DateTime(2026, 11, 12, 11, 0);
      final modified = original.copyWith(
        noteText: 'نص جديد ومحدث',
        updatedAt: updatedDate,
      );

      expect(modified.id, equals('note_1'));
      expect(modified.noteText, equals('نص جديد ومحدث'));
      expect(modified.updatedAt, equals(updatedDate));
      expect(modified.createdAt, equals(date));
    });
  });
}

