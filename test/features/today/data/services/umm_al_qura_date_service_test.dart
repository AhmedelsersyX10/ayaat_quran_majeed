import 'package:ayaat_quran_majeed/features/today/data/services/umm_al_qura_date_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = UmmAlQuraDateService();

  group('UmmAlQuraDateService Unit Tests', () {
    test('converts 2023-10-30 to 15 Rabi al-Thani 1445', () {
      final civilDate = DateTime(2023, 10, 30);
      final hijriInfo = service.getHijriDate(civilDate, hijriOffset: 0);

      expect(hijriInfo.day, 15);
      expect(hijriInfo.month, 4);
      expect(hijriInfo.year, 1445);
      expect(hijriInfo.dayArabic, '١٥');
      expect(hijriInfo.monthArabic, 'ربيع الثاني');
    });

    test(
      'converts 2023-12-03 to 19 Jumada al-Ula 1445 matching reference 16',
      () {
        final civilDate = DateTime(2023, 12, 3);
        final hijriInfo = service.getHijriDate(civilDate, hijriOffset: 0);

        expect(hijriInfo.day, 19);
        expect(hijriInfo.month, 5);
        expect(hijriInfo.year, 1445);
        expect(hijriInfo.dayArabic, '١٩');
        expect(hijriInfo.monthArabic, 'جمادى الأولى');
      },
    );

    test(
      'extracts Gregorian date info with Eastern Arabic numerals and Arabic month',
      () {
        final civilDate = DateTime(2023, 10, 30);
        final gregorianInfo = service.getGregorianDate(civilDate);

        expect(gregorianInfo.day, 30);
        expect(gregorianInfo.month, 10);
        expect(gregorianInfo.year, 2023);
        expect(gregorianInfo.dayArabic, '٣٠');
        expect(gregorianInfo.monthArabic, 'أكتوبر');
      },
    );

    test('applies hijriOffset +1 day shift correctly', () {
      final civilDate = DateTime(2023, 10, 30);
      final hijriPlus1 = service.getHijriDate(civilDate, hijriOffset: 1);

      expect(hijriPlus1.day, 16);
      expect(hijriPlus1.dayArabic, '١٦');
      expect(hijriPlus1.monthArabic, 'ربيع الثاني');
    });

    test('applies hijriOffset -1 day shift correctly', () {
      final civilDate = DateTime(2023, 10, 30);
      final hijriMinus1 = service.getHijriDate(civilDate, hijriOffset: -1);

      expect(hijriMinus1.day, 14);
      expect(hijriMinus1.dayArabic, '١٤');
      expect(hijriMinus1.monthArabic, 'ربيع الثاني');
    });
  });
}
