import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StarredAyahItem Entity Tests', () {
    test('key returns canonical "surah:verse" format', () {
      const item = StarredAyahItem(
        surahNumber: 2,
        verseNumber: 255,
        pageNumber: 42,
        ayahText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        surahName: 'البقرة',
      );
      expect(item.key, equals('2:255'));
    });

    test('equality and hashCode evaluate properly based on surah and verse', () {
      const item1 = StarredAyahItem(
        surahNumber: 2,
        verseNumber: 255,
        pageNumber: 42,
        ayahText: 'Text A',
        surahName: 'البقرة',
      );
      const item2 = StarredAyahItem(
        surahNumber: 2,
        verseNumber: 255,
        pageNumber: 43,
        ayahText: 'Text B',
        surahName: 'البقرة',
      );
      const item3 = StarredAyahItem(
        surahNumber: 3,
        verseNumber: 255,
        pageNumber: 42,
        ayahText: 'Text A',
        surahName: 'آل عمران',
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
      expect(item1, isNot(equals(item3)));
    });

    test('copyWith updates fields correctly', () {
      const original = StarredAyahItem(
        surahNumber: 1,
        verseNumber: 1,
        pageNumber: 1,
        ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        surahName: 'الفاتحة',
      );

      final updated = original.copyWith(
        verseNumber: 2,
        ayahText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      );

      expect(updated.surahNumber, equals(1));
      expect(updated.verseNumber, equals(2));
      expect(updated.pageNumber, equals(1));
      expect(updated.ayahText, equals('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'));
      expect(updated.surahName, equals('الفاتحة'));
    });
  });
}

