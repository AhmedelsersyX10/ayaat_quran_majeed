import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_29_day_table.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const metadataService = QuranMetadataService();

  group('Khatma29DayTable Structure and Metadata', () {
    test('contains exactly 29 days', () {
      expect(Khatma29DayTable.totalDays, equals(29));
      expect(Khatma29DayTable.days.length, equals(29));
    });

    test('day numbers are sequentially 1 through 29', () {
      for (int i = 0; i < 29; i++) {
        expect(Khatma29DayTable.days[i].dayNumber, equals(i + 1));
      }
    });

    test('getDay retrieves corresponding entry and validates boundaries', () {
      for (int i = 1; i <= 29; i++) {
        final entry = Khatma29DayTable.getDay(i);
        expect(entry.dayNumber, equals(i));
        expect(entry, equals(Khatma29DayTable.days[i - 1]));
      }

      expect(() => Khatma29DayTable.getDay(0), throwsArgumentError);
      expect(() => Khatma29DayTable.getDay(30), throwsArgumentError);
      expect(() => Khatma29DayTable.getDay(-5), throwsArgumentError);
    });
  });

  group('Khatma29DayTable Exhaustive Row-by-Row Tests (Screenshots 24, 25, 33, 35 & AGENTS.md)', () {
    test('Row 1: Al-Fatihah 1:1 -> Al-Baqarah 2:141 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(1);
      expect(entry.dayNumber, equals(1));
      expect(entry.dayTitle, equals('ورد اليوم ١'));
      expect(entry.startSurah, equals(1));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(2));
      expect(entry.endAyah, equals(141));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من الفاتحة إلى البقرة: ١٤١'));
      expect(entry.displayTitle, equals('من الفاتحة إلى البقرة: ١٤١'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(1));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(21));
    });

    test('Row 2: Al-Baqarah 2:142 -> 2:252 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(2);
      expect(entry.dayNumber, equals(2));
      expect(entry.dayTitle, equals('ورد اليوم ٢'));
      expect(entry.startSurah, equals(2));
      expect(entry.startAyah, equals(142));
      expect(entry.endSurah, equals(2));
      expect(entry.endAyah, equals(252));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من البقرة: ١٤٢ إلى البقرة: ٢٥٢'));
      expect(entry.displayTitle, equals('من البقرة: ١٤٢ إلى البقرة: ٢٥٢'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(22));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(41));
    });

    test('Row 3: Al-Baqarah 2:253 -> Aal-Imran 3:92 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(3);
      expect(entry.dayNumber, equals(3));
      expect(entry.dayTitle, equals('ورد اليوم ٣'));
      expect(entry.startSurah, equals(2));
      expect(entry.startAyah, equals(253));
      expect(entry.endSurah, equals(3));
      expect(entry.endAyah, equals(92));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من البقرة: ٢٥٣ إلى آل عمران: ٩٢'));
      expect(entry.displayTitle, equals('من البقرة: ٢٥٣ إلى آل عمران: ٩٢'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(42));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(62));
    });

    test('Row 4: Aal-Imran 3:93 -> An-Nisa 4:35 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(4);
      expect(entry.dayNumber, equals(4));
      expect(entry.dayTitle, equals('ورد اليوم ٤'));
      expect(entry.startSurah, equals(3));
      expect(entry.startAyah, equals(93));
      expect(entry.endSurah, equals(4));
      expect(entry.endAyah, equals(35));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من آل عمران: ٩٣ إلى النساء: ٣٥'));
      expect(entry.displayTitle, equals('من آل عمران: ٩٣ إلى النساء: ٣٥'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(62));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(84));
    });

    test('Row 5: An-Nisa 4:36 -> An-Nisa 4:176 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(5);
      expect(entry.dayNumber, equals(5));
      expect(entry.dayTitle, equals('ورد اليوم ٥'));
      expect(entry.startSurah, equals(4));
      expect(entry.startAyah, equals(36));
      expect(entry.endSurah, equals(4));
      expect(entry.endAyah, equals(176));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من النساء: ٣٦ إلى نهاية النساء'));
      expect(entry.displayTitle, equals('من النساء: ٣٦ إلى نهاية النساء'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(84));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(106));
    });

    test('Row 6: Al-Ma\'idah 5:1 -> 5:120 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(6);
      expect(entry.dayNumber, equals(6));
      expect(entry.dayTitle, equals('ورد اليوم ٦'));
      expect(entry.startSurah, equals(5));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(5));
      expect(entry.endAyah, equals(120));
      expect(entry.customTitle, equals('المائدة'));
      expect(entry.rangeText, equals('المائدة'));
      expect(entry.displayTitle, equals('المائدة'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(106));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(127));
    });

    test('Row 7: Al-An\'am 6:1 -> 6:165 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(7);
      expect(entry.dayNumber, equals(7));
      expect(entry.dayTitle, equals('ورد اليوم ٧'));
      expect(entry.startSurah, equals(6));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(6));
      expect(entry.endAyah, equals(165));
      expect(entry.customTitle, equals('الأنعام'));
      expect(entry.rangeText, equals('الأنعام'));
      expect(entry.displayTitle, equals('الأنعام'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(128));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(150));
    });

    test('Row 8: Al-A\'raf 7:1 -> 7:206 (Screenshots 24, 35)', () {
      final entry = Khatma29DayTable.getDay(8);
      expect(entry.dayNumber, equals(8));
      expect(entry.dayTitle, equals('ورد اليوم ٨'));
      expect(entry.startSurah, equals(7));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(7));
      expect(entry.endAyah, equals(206));
      expect(entry.customTitle, equals('الأعراف'));
      expect(entry.rangeText, equals('الأعراف'));
      expect(entry.displayTitle, equals('الأعراف'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(151));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(176));
    });

    test('Row 9: Al-Anfal 8:1 -> At-Tawbah 9:72 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(9);
      expect(entry.dayNumber, equals(9));
      expect(entry.dayTitle, equals('ورد اليوم ٩'));
      expect(entry.startSurah, equals(8));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(9));
      expect(entry.endAyah, equals(72));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من الأنفال إلى التوبة: ٧٢'));
      expect(entry.displayTitle, equals('من الأنفال إلى التوبة: ٧٢'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(177));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(198));
    });

    test('Row 10: At-Tawbah 9:73 -> Yunus 10:109 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(10);
      expect(entry.dayNumber, equals(10));
      expect(entry.dayTitle, equals('ورد اليوم ١٠'));
      expect(entry.startSurah, equals(9));
      expect(entry.startAyah, equals(73));
      expect(entry.endSurah, equals(10));
      expect(entry.endAyah, equals(109));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من التوبة: ٧٣ إلى نهاية يونس'));
      expect(entry.displayTitle, equals('من التوبة: ٧٣ إلى نهاية يونس'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(199));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(221));
    });

    test('Row 11: Hud 11:1 -> Yusuf 12:57 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(11);
      expect(entry.dayNumber, equals(11));
      expect(entry.dayTitle, equals('ورد اليوم ١١'));
      expect(entry.startSurah, equals(11));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(12));
      expect(entry.endAyah, equals(57));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من هود إلى يوسف: ٥٧'));
      expect(entry.displayTitle, equals('من هود إلى يوسف: ٥٧'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(221));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(242));
    });

    test('Row 12: Yusuf 12:58 -> Ibrahim 14:52 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(12);
      expect(entry.dayNumber, equals(12));
      expect(entry.dayTitle, equals('ورد اليوم ١٢'));
      expect(entry.startSurah, equals(12));
      expect(entry.startAyah, equals(58));
      expect(entry.endSurah, equals(14));
      expect(entry.endAyah, equals(52));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من يوسف: ٥٨ إلى نهاية إبراهيم'));
      expect(entry.displayTitle, equals('من يوسف: ٥٨ إلى نهاية إبراهيم'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(242));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(261));
    });

    test('Row 13: Al-Hijr 15:1 -> An-Nahl 16:128 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(13);
      expect(entry.dayNumber, equals(13));
      expect(entry.dayTitle, equals('ورد اليوم ١٣'));
      expect(entry.startSurah, equals(15));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(16));
      expect(entry.endAyah, equals(128));
      expect(entry.customTitle, equals('الحجر و النحل'));
      expect(entry.rangeText, equals('الحجر و النحل'));
      expect(entry.displayTitle, equals('الحجر و النحل'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(262));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(281));
    });

    test('Row 14: Al-Isra 17:1 -> Al-Kahf 18:110 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(14);
      expect(entry.dayNumber, equals(14));
      expect(entry.dayTitle, equals('ورد اليوم ١٤'));
      expect(entry.startSurah, equals(17));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(18));
      expect(entry.endAyah, equals(110));
      expect(entry.customTitle, equals('الإسراء و الكهف'));
      expect(entry.rangeText, equals('الإسراء و الكهف'));
      expect(entry.displayTitle, equals('الإسراء و الكهف'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(282));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(304));
    });

    test('Row 15: Maryam 19:1 -> Ta-Ha 20:135 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(15);
      expect(entry.dayNumber, equals(15));
      expect(entry.dayTitle, equals('ورد اليوم ١٥'));
      expect(entry.startSurah, equals(19));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(20));
      expect(entry.endAyah, equals(135));
      expect(entry.customTitle, equals('مريم و طه'));
      expect(entry.rangeText, equals('مريم و طه'));
      expect(entry.displayTitle, equals('مريم و طه'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(305));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(321));
    });

    test('Row 16: Al-Anbiya 21:1 -> Al-Hajj 22:78 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(16);
      expect(entry.dayNumber, equals(16));
      expect(entry.dayTitle, equals('ورد اليوم ١٦'));
      expect(entry.startSurah, equals(21));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(22));
      expect(entry.endAyah, equals(78));
      expect(entry.customTitle, equals('الأنبياء و الحج'));
      expect(entry.rangeText, equals('الأنبياء و الحج'));
      expect(entry.displayTitle, equals('الأنبياء و الحج'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(322));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(341));
    });

    test('Row 17: Al-Mu\'minun 23:1 -> An-Nur 24:64 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(17);
      expect(entry.dayNumber, equals(17));
      expect(entry.dayTitle, equals('ورد اليوم ١٧'));
      expect(entry.startSurah, equals(23));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(24));
      expect(entry.endAyah, equals(64));
      expect(entry.customTitle, equals('المؤمنون و النور'));
      expect(entry.rangeText, equals('المؤمنون و النور'));
      expect(entry.displayTitle, equals('المؤمنون و النور'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(342));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(359));
    });

    test('Row 18: Al-Furqan 25:1 -> Ash-Shu\'ara 26:227 (Screenshot 35)', () {
      final entry = Khatma29DayTable.getDay(18);
      expect(entry.dayNumber, equals(18));
      expect(entry.dayTitle, equals('ورد اليوم ١٨'));
      expect(entry.startSurah, equals(25));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(26));
      expect(entry.endAyah, equals(227));
      expect(entry.customTitle, equals('الفرقان و الشعراء'));
      expect(entry.rangeText, equals('الفرقان و الشعراء'));
      expect(entry.displayTitle, equals('الفرقان و الشعراء'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(359));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(376));
    });

    test('Row 19: An-Naml 27:1 -> Al-Qasas 28:88 (Screenshot 33)', () {
      final entry = Khatma29DayTable.getDay(19);
      expect(entry.dayNumber, equals(19));
      expect(entry.dayTitle, equals('ورد اليوم ١٩'));
      expect(entry.startSurah, equals(27));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(28));
      expect(entry.endAyah, equals(88));
      expect(entry.customTitle, equals('النمل و القصص'));
      expect(entry.rangeText, equals('النمل و القصص'));
      expect(entry.displayTitle, equals('النمل و القصص'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(377));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(396));
    });

    test('Row 20: Al-Ankabut 29:1 -> As-Sajdah 32:30 (Screenshot 33)', () {
      final entry = Khatma29DayTable.getDay(20);
      expect(entry.dayNumber, equals(20));
      expect(entry.dayTitle, equals('ورد اليوم ٢٠'));
      expect(entry.startSurah, equals(29));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(32));
      expect(entry.endAyah, equals(30));
      expect(entry.customTitle, equals('العنكبوت و الروم و لقمان و السجدة'));
      expect(entry.rangeText, equals('العنكبوت و الروم و لقمان و السجدة'));
      expect(entry.displayTitle, equals('العنكبوت و الروم و لقمان و السجدة'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(396));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(417));
    });

    test('Row 21: Al-Ahzab 33:1 -> Fatir 35:45 (Screenshot 33)', () {
      final entry = Khatma29DayTable.getDay(21);
      expect(entry.dayNumber, equals(21));
      expect(entry.dayTitle, equals('ورد اليوم ٢١'));
      expect(entry.startSurah, equals(33));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(35));
      expect(entry.endAyah, equals(45));
      expect(entry.customTitle, equals('الأحزاب و سبأ و فاطر'));
      expect(entry.rangeText, equals('الأحزاب و سبأ و فاطر'));
      expect(entry.displayTitle, equals('الأحزاب و سبأ و فاطر'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(418));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(440));
    });

    test('Row 22: Ya-Sin 36:1 -> Sad 38:88 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(22);
      expect(entry.dayNumber, equals(22));
      expect(entry.dayTitle, equals('ورد اليوم ٢٢'));
      expect(entry.startSurah, equals(36));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(38));
      expect(entry.endAyah, equals(88));
      expect(entry.customTitle, equals('يس و الصافات و ص'));
      expect(entry.rangeText, equals('يس و الصافات و ص'));
      expect(entry.displayTitle, equals('يس و الصافات و ص'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(440));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(458));
    });

    test('Row 23: Az-Zumar 39:1 -> Ghafir 40:85 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(23);
      expect(entry.dayNumber, equals(23));
      expect(entry.dayTitle, equals('ورد اليوم ٢٣'));
      expect(entry.startSurah, equals(39));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(40));
      expect(entry.endAyah, equals(85));
      expect(entry.customTitle, equals('الزمر و غافر'));
      expect(entry.rangeText, equals('الزمر و غافر'));
      expect(entry.displayTitle, equals('الزمر و غافر'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(458));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(476));
    });

    test('Row 24: Fussilat 41:1 -> Ad-Dukhan 44:59 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(24);
      expect(entry.dayNumber, equals(24));
      expect(entry.dayTitle, equals('ورد اليوم ٢٤'));
      expect(entry.startSurah, equals(41));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(44));
      expect(entry.endAyah, equals(59));
      expect(entry.customTitle, equals('فصلت و الشورى و الزخرف و الدخان'));
      expect(entry.rangeText, equals('فصلت و الشورى و الزخرف و الدخان'));
      expect(entry.displayTitle, equals('فصلت و الشورى و الزخرف و الدخان'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(477));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(498));
    });

    test('Row 25: Al-Jathiyah 45:1 -> Al-Hujurat 49:18 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(25);
      expect(entry.dayNumber, equals(25));
      expect(entry.dayTitle, equals('ورد اليوم ٢٥'));
      expect(entry.startSurah, equals(45));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(49));
      expect(entry.endAyah, equals(18));
      expect(entry.customTitle, equals('الجاثية و الأحقاف و محمد و الفتح و الحجرات'));
      expect(entry.rangeText, equals('الجاثية و الأحقاف و محمد و الفتح و الحجرات'));
      expect(entry.displayTitle, equals('الجاثية و الأحقاف و محمد و الفتح و الحجرات'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(499));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(517));
    });

    test('Row 26: Qaf 50:1 -> Al-Hadid 57:29 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(26);
      expect(entry.dayNumber, equals(26));
      expect(entry.dayTitle, equals('ورد اليوم ٢٦'));
      expect(entry.startSurah, equals(50));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(57));
      expect(entry.endAyah, equals(29));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من ق إلى الحديد'));
      expect(entry.displayTitle, equals('من ق إلى الحديد'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(518));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(541));
    });

    test('Row 27: Al-Mujadila 58:1 -> At-Tahrim 66:12 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(27);
      expect(entry.dayNumber, equals(27));
      expect(entry.dayTitle, equals('ورد اليوم ٢٧'));
      expect(entry.startSurah, equals(58));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(66));
      expect(entry.endAyah, equals(12));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من المجادلة إلى التحريم'));
      expect(entry.displayTitle, equals('من المجادلة إلى التحريم'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(542));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(561));
    });

    test('Row 28: Al-Mulk 67:1 -> Al-Mursalat 77:50 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(28);
      expect(entry.dayNumber, equals(28));
      expect(entry.dayTitle, equals('ورد اليوم ٢٨'));
      expect(entry.startSurah, equals(67));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(77));
      expect(entry.endAyah, equals(50));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من الملك إلى المرسلات'));
      expect(entry.displayTitle, equals('من الملك إلى المرسلات'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(562));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(581));
    });

    test('Row 29: An-Naba 78:1 -> An-Nas 114:6 (Screenshots 25, 33)', () {
      final entry = Khatma29DayTable.getDay(29);
      expect(entry.dayNumber, equals(29));
      expect(entry.dayTitle, equals('ورد اليوم ٢٩'));
      expect(entry.startSurah, equals(78));
      expect(entry.startAyah, equals(1));
      expect(entry.endSurah, equals(114));
      expect(entry.endAyah, equals(6));
      expect(entry.customTitle, isNull);
      expect(entry.rangeText, equals('من النبأ إلى الناس'));
      expect(entry.displayTitle, equals('من النبأ إلى الناس'));
      expect(metadataService.getPageNumber(entry.startSurah, entry.startAyah), equals(582));
      expect(metadataService.getPageNumber(entry.endSurah, entry.endAyah), equals(604));
    });
  });

  group('Khatma29DayTable Quran Continuity & Full Coverage', () {
    test('starts at the very first verse (1:1) and ends at the very last verse (114:6)', () {
      final first = Khatma29DayTable.getDay(1);
      final last = Khatma29DayTable.getDay(29);

      expect(first.startSurah, equals(1));
      expect(first.startAyah, equals(1));
      expect(last.endSurah, equals(114));
      expect(last.endAyah, equals(6));
    });

    test('verifies perfect continuity between all 28 consecutive day boundaries', () {
      for (int i = 0; i < 28; i++) {
        final current = Khatma29DayTable.days[i];
        final next = Khatma29DayTable.days[i + 1];

        if (next.startSurah == current.endSurah) {
          // Continued in the same surah
          expect(
            next.startAyah,
            equals(current.endAyah + 1),
            reason: 'Gap between Day ${current.dayNumber} and Day ${next.dayNumber} in Surah ${current.endSurah}',
          );
        } else {
          // Surah transition
          expect(
            next.startSurah,
            equals(current.endSurah + 1),
            reason: 'Surah gap between Day ${current.dayNumber} and Day ${next.dayNumber}',
          );
          expect(
            next.startAyah,
            equals(1),
            reason: 'Next day ${next.dayNumber} must begin at Ayah 1 of Surah ${next.startSurah}',
          );
          final expectedEndCount = metadataService.getVerseCount(current.endSurah);
          expect(
            current.endAyah,
            equals(expectedEndCount),
            reason: 'Day ${current.dayNumber} did not terminate at the last verse of Surah ${current.endSurah}',
          );
        }
      }
    });

    test('every page from 1 to 604 is encompassed continuously', () {
      final firstPage = metadataService.getPageNumber(
        Khatma29DayTable.days.first.startSurah,
        Khatma29DayTable.days.first.startAyah,
      );
      final lastPage = metadataService.getPageNumber(
        Khatma29DayTable.days.last.endSurah,
        Khatma29DayTable.days.last.endAyah,
      );

      expect(firstPage, equals(1));
      expect(lastPage, equals(604));

      for (int i = 0; i < 28; i++) {
        final currentEndPage = metadataService.getPageNumber(
          Khatma29DayTable.days[i].endSurah,
          Khatma29DayTable.days[i].endAyah,
        );
        final nextStartPage = metadataService.getPageNumber(
          Khatma29DayTable.days[i + 1].startSurah,
          Khatma29DayTable.days[i + 1].startAyah,
        );

        // Next day either starts on the same page or the immediately following page
        expect(
          nextStartPage == currentEndPage || nextStartPage == currentEndPage + 1,
          isTrue,
          reason: 'Page gap between day ${i + 1} (p. $currentEndPage) and day ${i + 2} (p. $nextStartPage)',
        );
      }
    });
  });

  group('Khatma29DayTable findDayNumberForAyah Lookup Tests', () {
    test('correctly identifies day numbers for boundary and interior verses', () {
      // Day 1
      expect(Khatma29DayTable.findDayNumberForAyah(1, 1), equals(1));
      expect(Khatma29DayTable.findDayNumberForAyah(1, 7), equals(1));
      expect(Khatma29DayTable.findDayNumberForAyah(2, 1), equals(1));
      expect(Khatma29DayTable.findDayNumberForAyah(2, 141), equals(1));

      // Day 2
      expect(Khatma29DayTable.findDayNumberForAyah(2, 142), equals(2));
      expect(Khatma29DayTable.findDayNumberForAyah(2, 200), equals(2));
      expect(Khatma29DayTable.findDayNumberForAyah(2, 252), equals(2));

      // Day 3
      expect(Khatma29DayTable.findDayNumberForAyah(2, 253), equals(3));
      expect(Khatma29DayTable.findDayNumberForAyah(3, 92), equals(3));

      // Day 4
      expect(Khatma29DayTable.findDayNumberForAyah(3, 93), equals(4));
      expect(Khatma29DayTable.findDayNumberForAyah(4, 35), equals(4));

      // Day 5
      expect(Khatma29DayTable.findDayNumberForAyah(4, 36), equals(5));
      expect(Khatma29DayTable.findDayNumberForAyah(4, 176), equals(5));

      // Day 6
      expect(Khatma29DayTable.findDayNumberForAyah(5, 1), equals(6));
      expect(Khatma29DayTable.findDayNumberForAyah(5, 120), equals(6));

      // Day 20 (middle surah: Ar-Rum 30:1)
      expect(Khatma29DayTable.findDayNumberForAyah(30, 1), equals(20));

      // Day 29
      expect(Khatma29DayTable.findDayNumberForAyah(78, 1), equals(29));
      expect(Khatma29DayTable.findDayNumberForAyah(114, 6), equals(29));
    });

    test('throws ArgumentError on invalid surah or ayah inputs', () {
      expect(() => Khatma29DayTable.findDayNumberForAyah(0, 1), throwsArgumentError);
      expect(() => Khatma29DayTable.findDayNumberForAyah(115, 1), throwsArgumentError);
      expect(() => Khatma29DayTable.findDayNumberForAyah(1, 0), throwsArgumentError);
    });
  });

  group('Khatma29DayEntry Entity Equality and Representation', () {
    test('identical instances are equal and have identical hashCode', () {
      final e1 = Khatma29DayTable.getDay(1);
      const e2 = Khatma29DayEntry(
        dayNumber: 1,
        startSurah: 1,
        startAyah: 1,
        endSurah: 2,
        endAyah: 141,
        rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1.toString(), contains('day: 1'));
      expect(e1.toString(), contains('من الفاتحة إلى البقرة: ١٤١'));
    });
  });
}
