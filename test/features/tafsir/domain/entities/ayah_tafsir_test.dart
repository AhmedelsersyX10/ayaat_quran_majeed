import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/ayah_tafsir.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AyahTafsir Domain Entity Tests', () {
    const item1 = AyahTafsir(
      surahNumber: 2,
      ayahNumber: 6,
      pageNumber: 3,
      ayahText: 'إِنَّ الَّذِينَ كَفَرُوا سَوَاءٌ عَلَيْهِمْ',
      ayahEndSymbol: ' ﴿٦﴾ ',
      surahName: 'البَقَرَة',
      isFirstAyahOfSurah: false,
      tafsirText: 'إن الذين جحدوا ما أُنزل إليك من ربك...',
      bookId: 'ar_muyassar',
      bookName: 'التفسير الميسر',
    );

    const item2 = AyahTafsir(
      surahNumber: 2,
      ayahNumber: 6,
      pageNumber: 3,
      ayahText: 'إِنَّ الَّذِينَ كَفَرُوا سَوَاءٌ عَلَيْهِمْ',
      ayahEndSymbol: ' ﴿٦﴾ ',
      surahName: 'البَقَرَة',
      isFirstAyahOfSurah: false,
      tafsirText: 'إن الذين جحدوا ما أُنزل إليك من ربك...',
      bookId: 'ar_muyassar',
      bookName: 'التفسير الميسر',
    );

    test('value equality and hashCode contract work as expected', () {
      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('copyWith creates modified copy keeping unmodified properties', () {
      final modified = item1.copyWith(
        ayahNumber: 7,
        tafsirText: 'خَتَمَ الله على قلوبهم...',
      );

      expect(modified.surahNumber, equals(2));
      expect(modified.ayahNumber, equals(7));
      expect(modified.tafsirText, equals('خَتَمَ الله على قلوبهم...'));
      expect(modified.bookId, equals('ar_muyassar'));
      expect(modified, isNot(equals(item1)));
    });

    test('isFirstAyahOfSurah indicates header requirement accurately', () {
      final firstAyah = item1.copyWith(ayahNumber: 1, isFirstAyahOfSurah: true);
      expect(firstAyah.isFirstAyahOfSurah, isTrue);
      expect(item1.isFirstAyahOfSurah, isFalse);
    });

    test('toString contains key diagnostic details', () {
      final str = item1.toString();
      expect(str, contains('surah: 2'));
      expect(str, contains('ayah: 6'));
      expect(str, contains('page: 3'));
      expect(str, contains('book: ar_muyassar'));
    });
  });
}

