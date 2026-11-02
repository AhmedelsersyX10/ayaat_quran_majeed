import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Arabic Numbers Conversion Tests', () {
    test('toArabicDigits converts all basic Western ASCII digits to Eastern Arabic-Indic numerals', () {
      expect(toArabicDigits('0123456789'), equals('٠١٢٣٤٥٦٧٨٩'));
      expect(toArabicDigits(0), equals('٠'));
      expect(toArabicDigits(114), equals('١١٤'));
      expect(toArabicDigits(604), equals('٦٠٤'));
      expect(toArabicDigits(6236), equals('٦٢٣٦'));
    });

    test('toArabicDigits preserves non-digit characters, punctuation, and Arabic text safely', () {
      expect(toArabicDigits('الفاتحة: 5'), equals('الفاتحة: ٥'));
      expect(toArabicDigits('12:30'), equals('١٢:٣٠'));
      expect(toArabicDigits('1-18'), equals('١-١٨'));
      expect(toArabicDigits('3/4'), equals('٣/٤'));
      expect(toArabicDigits('-5'), equals('-٥'));
      expect(toArabicDigits('3.14'), equals('٣.١٤'));
      expect(toArabicDigits(''), equals(''));
      expect(toArabicDigits(null), equals(''));
    });

    test('toWesternDigits converts Eastern Arabic-Indic numerals back to Western ASCII digits', () {
      expect(toWesternDigits('٠١٢٣٤٥٦٧٨٩'), equals('0123456789'));
      expect(toWesternDigits('١١٤'), equals('114'));
      expect(toWesternDigits('٦٠٤'), equals('604'));
      expect(toWesternDigits('الفاتحة: ٥'), equals('الفاتحة: 5'));
      expect(toWesternDigits('١٢:٣٠ م'), equals('12:30 م'));
    });

    test('parseArabicInt parses Arabic-Indic strings into integer accurately', () {
      expect(parseArabicInt('١١٤'), equals(114));
      expect(parseArabicInt('٦٠٤'), equals(604));
      expect(parseArabicInt(' ٧ '), equals(7));
      expect(parseArabicInt('٠'), equals(0));
      expect(parseArabicInt('invalid'), isNull);
    });
  });

  group('Semantic Date, Time & Label Formatters Tests', () {
    test('formatArabicTime formats 12-hour times with Arabic AM/PM markers', () {
      expect(formatArabicTime(hour: 7, minute: 30), equals('٧:٣٠ ص'));
      expect(formatArabicTime(hour: 21, minute: 32), equals('٩:٣٢ م'));
      expect(formatArabicTime(hour: 12, minute: 0), equals('١٢:٠٠ م'));
      expect(formatArabicTime(hour: 0, minute: 15), equals('١٢:١٥ ص'));
    });

    test('formatArabicTime formats 24-hour time when requested', () {
      expect(formatArabicTime(hour: 7, minute: 5, is24Hour: true), equals('٠٧:٠٥'));
      expect(formatArabicTime(hour: 23, minute: 45, is24Hour: true), equals('٢٣:٤٥'));
    });

    test('formatArabicDate formats Gregorian date in Arabic with Arabic month names', () {
      final date = DateTime(2023, 10, 30);
      expect(formatArabicDate(date), equals('٣٠ أكتوبر ٢٠٢٣'));
      expect(formatArabicDate(date, includeYear: false), equals('٣٠ أكتوبر'));
      // 2023-10-30 was a Monday (الاثنين)
      expect(formatArabicDate(date, includeDayName: true), equals('الاثنين ٣٠ أكتوبر ٢٠٢٣'));
    });

    test('formatAyahLabel formats surah and verse reference', () {
      expect(formatAyahLabel('الفاتحة', 5), equals('الفاتحة: ٥'));
      expect(formatAyahLabel('البقرة', 255), equals('البقرة: ٢٥٥'));
    });

    test('formatPageAyahLabel matches screens 27 and 30 format', () {
      expect(
        formatPageAyahLabel(surahName: 'البقرة', ayahNumber: 6, pageNumber: 3),
        equals('البقرة: ٦ - الصفحة ٣'),
      );
      expect(
        formatPageAyahLabel(surahName: 'الفاتحة', ayahNumber: 7, pageNumber: 1),
        equals('الفاتحة: ٧ - الصفحة ١'),
      );
    });

    test('formatSurahHeader matches screen 03 format', () {
      expect(
        formatSurahHeader(pageNumber: 2, versesCount: 286, isMakki: false),
        equals('الصفحة ٢ - آياتها ٢٨٦ - مدنية'),
      );
      expect(
        formatSurahHeader(pageNumber: 1, versesCount: 7, isMakki: true),
        equals('الصفحة ١ - آياتها ٧ - مكية'),
      );
    });

    test('formatJuzOrdinal provides accurate ordinal names for all 30 Juz parts', () {
      expect(formatJuzOrdinal(1), equals('الجزء الأول'));
      expect(formatJuzOrdinal(2), equals('الجزء الثاني'));
      expect(formatJuzOrdinal(3), equals('الجزء الثالث'));
      expect(formatJuzOrdinal(10), equals('الجزء العاشر'));
      expect(formatJuzOrdinal(20), equals('الجزء العشرون'));
      expect(formatJuzOrdinal(30), equals('الجزء الثلاثون'));
    });

    test('formatHizbQuarter formats quarter and hizb markers matching screen 04', () {
      expect(formatHizbQuarter(hizbNumber: 1, quarterIndex: 0), equals('الحزب ١'));
      expect(formatHizbQuarter(hizbNumber: 1, quarterIndex: 1), equals('ربع الحزب ١'));
      expect(formatHizbQuarter(hizbNumber: 1, quarterIndex: 2), equals('نصف الحزب ١'));
      expect(formatHizbQuarter(hizbNumber: 1, quarterIndex: 3), equals('ثلاثة أرباع الحزب ١'));
      expect(formatHizbQuarter(hizbNumber: 2, quarterIndex: 0), equals('الحزب ٢'));
    });

    test('formatKhatmaDays handles singular/plural rules for days count', () {
      expect(formatKhatmaDays(3), equals('٣ أيام'));
      expect(formatKhatmaDays(7), equals('٧ أيام'));
      expect(formatKhatmaDays(10), equals('١٠ أيام'));
      expect(formatKhatmaDays(30), equals('٣٠ يوما'));
      expect(formatKhatmaDays(240), equals('٢٤٠ يوما'));
    });
  });
}

