import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_surah_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteSurahGroup Entity Tests', () {
    String surahNameResolver(int surah) {
      switch (surah) {
        case 1:
          return 'الفاتحة';
        case 2:
          return 'البقرة';
        case 3:
          return 'آل عمران';
        default:
          return 'سورة $surah';
      }
    }

    test('groupNotes returns empty list when items are empty', () {
      final groups = NoteSurahGroup.groupNotes(
        items: [],
        surahNameResolver: surahNameResolver,
      );
      expect(groups, isEmpty);
    });

    test(
      'groupNotes sorts surahs ascending, verses ascending, and multiple notes by createdAt descending',
      () {
        final t1 = DateTime(2026, 11, 1, 10, 0);
        final t2 = DateTime(2026, 11, 2, 10, 0); // newer
        final t3 = DateTime(2026, 11, 3, 10, 0); // newest

        final items = [
          // Surah 2, Ayah 4 (older note)
          NoteItem(
            id: 'n1',
            surahNumber: 2,
            verseNumber: 4,
            pageNumber: 2,
            noteText: 'ملاحظة قديمة على آية 4',
            createdAt: t1,
          ),
          // Surah 1, Ayah 1
          NoteItem(
            id: 'n2',
            surahNumber: 1,
            verseNumber: 1,
            pageNumber: 1,
            noteText: 'بسم الله',
            createdAt: t1,
          ),
          // Surah 2, Ayah 4 (newer note on same ayah)
          NoteItem(
            id: 'n3',
            surahNumber: 2,
            verseNumber: 4,
            pageNumber: 2,
            noteText: 'ملاحظة جديدة على آية 4',
            createdAt: t3,
          ),
          // Surah 2, Ayah 2
          NoteItem(
            id: 'n4',
            surahNumber: 2,
            verseNumber: 2,
            pageNumber: 2,
            noteText: 'ذلك الكتاب',
            createdAt: t2,
          ),
        ];

        final groups = NoteSurahGroup.groupNotes(
          items: items,
          surahNameResolver: surahNameResolver,
        );

        expect(groups.length, equals(2));

        // Group 1: Al-Fatihah (Surah 1)
        expect(groups[0].surahNumber, equals(1));
        expect(groups[0].surahName, equals('الفاتحة'));
        expect(groups[0].notes.length, equals(1));
        expect(groups[0].notes[0].id, equals('n2'));

        // Group 2: Al-Baqarah (Surah 2)
        expect(groups[1].surahNumber, equals(2));
        expect(groups[1].surahName, equals('البقرة'));
        expect(groups[1].notes.length, equals(3));

        // Verse ordering within Al-Baqarah:
        // First should be Ayah 2
        expect(groups[1].notes[0].verseNumber, equals(2));
        expect(groups[1].notes[0].id, equals('n4'));

        // Next two should be Ayah 4, ordered newest first (t3 then t1)
        expect(groups[1].notes[1].verseNumber, equals(4));
        expect(groups[1].notes[1].id, equals('n3')); // newest (t3)
        expect(groups[1].notes[2].verseNumber, equals(4));
        expect(groups[1].notes[2].id, equals('n1')); // older (t1)
      },
    );
  });
}

