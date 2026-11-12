import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_surah_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StarredSurahGroup Entity Tests', () {
    test('groupBySurah returns empty list when items are empty', () {
      final groups = StarredSurahGroup.groupBySurah([]);
      expect(groups, isEmpty);
    });

    test(
      'groupBySurah groups deterministically: surahs ascending, verses ascending',
      () {
        // Items intentionally in scrambled order across multiple surahs
        final items = [
          const StarredAyahItem(
            surahNumber: 2,
            verseNumber: 5,
            pageNumber: 2,
            ayahText: 'أُوْلَـٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ',
            surahName: 'البقرة',
          ),
          const StarredAyahItem(
            surahNumber: 1,
            verseNumber: 7,
            pageNumber: 1,
            ayahText: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
            surahName: 'الفاتحة',
          ),
          const StarredAyahItem(
            surahNumber: 2,
            verseNumber: 2,
            pageNumber: 2,
            ayahText: 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ',
            surahName: 'البقرة',
          ),
          const StarredAyahItem(
            surahNumber: 1,
            verseNumber: 1,
            pageNumber: 1,
            ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            surahName: 'الفاتحة',
          ),
          const StarredAyahItem(
            surahNumber: 2,
            verseNumber: 4,
            pageNumber: 2,
            ayahText: 'وَٱلَّذِينَ يُؤْمِنُونَ بِمَآ أُنزِلَ إِلَيْكَ',
            surahName: 'البقرة',
          ),
        ];

        final groups = StarredSurahGroup.groupBySurah(items);

        // Expect 2 groups in order: Surah 1 (الفاتحة), then Surah 2 (البقرة)
        expect(groups.length, equals(2));

        // Group 1: Al-Fatihah
        expect(groups[0].surahNumber, equals(1));
        expect(groups[0].surahName, equals('الفاتحة'));
        expect(groups[0].items.length, equals(2));
        expect(groups[0].items[0].verseNumber, equals(1));
        expect(groups[0].items[1].verseNumber, equals(7));

        // Group 2: Al-Baqarah (matching screenshot 28 order: 2, 4, 5)
        expect(groups[1].surahNumber, equals(2));
        expect(groups[1].surahName, equals('البقرة'));
        expect(groups[1].items.length, equals(3));
        expect(groups[1].items[0].verseNumber, equals(2));
        expect(groups[1].items[1].verseNumber, equals(4));
        expect(groups[1].items[2].verseNumber, equals(5));
      },
    );

    test('equality evaluates properly based on surahNumber, surahName, and items', () {
      const item1 = StarredAyahItem(
        surahNumber: 2,
        verseNumber: 2,
        pageNumber: 2,
        ayahText: 'Ayah 2',
        surahName: 'البقرة',
      );
      const groupA = StarredSurahGroup(
        surahNumber: 2,
        surahName: 'البقرة',
        items: [item1],
      );
      const groupB = StarredSurahGroup(
        surahNumber: 2,
        surahName: 'البقرة',
        items: [item1],
      );
      const groupC = StarredSurahGroup(
        surahNumber: 3,
        surahName: 'آل عمران',
        items: [],
      );

      expect(groupA, equals(groupB));
      expect(groupA.hashCode, equals(groupB.hashCode));
      expect(groupA, isNot(equals(groupC)));
    });
  });
}

