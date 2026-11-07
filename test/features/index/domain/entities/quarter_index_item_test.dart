import 'package:ayaat_quran_majeed/features/index/domain/entities/quarter_index_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuarterIndexItem Entity Tests', () {
    const item1 = QuarterIndexItem(
      quarterNumber: 1,
      hizbNumber: 1,
      quarterInHizb: 1,
      surahNumber: 1,
      surahNameArabic: 'الفاتحة',
      ayahNumber: 1,
      pageNumber: 1,
      ayahText: 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
    );

    const item2 = QuarterIndexItem(
      quarterNumber: 1,
      hizbNumber: 1,
      quarterInHizb: 1,
      surahNumber: 1,
      surahNameArabic: 'الفاتحة',
      ayahNumber: 1,
      pageNumber: 1,
      ayahText: 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
    );

    const itemDiff = QuarterIndexItem(
      quarterNumber: 2,
      hizbNumber: 1,
      quarterInHizb: 2,
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      ayahNumber: 26,
      pageNumber: 5,
      ayahText: 'إِنَّ اللَّهَ لَا يَسْتَحْىِۦٓ',
    );

    test('value equality and hashCode contract work as expected', () {
      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
      expect(item1, isNot(equals(itemDiff)));
    });

    test('copyWith produces modified copy while keeping unmodified fields', () {
      final modified = item1.copyWith(quarterNumber: 99, pageNumber: 200);
      expect(modified.quarterNumber, 99);
      expect(modified.pageNumber, 200);
      expect(modified.hizbNumber, item1.hizbNumber);
      expect(modified.surahNumber, item1.surahNumber);
      expect(modified.ayahText, item1.ayahText);
    });

    test('toString contains key identifying information', () {
      final str = item1.toString();
      expect(str, contains('quarter: 1'));
      expect(str, contains('hizb: 1'));
      expect(str, contains('الفاتحة'));
    });
  });
}
