import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuranMetadataService metadataService;
  late KhatmaWirdCalculator calculator;

  setUp(() {
    metadataService = const QuranMetadataService();
    calculator = KhatmaWirdCalculator(metadataService: metadataService);
  });

  group('KhatmaWirdCalculator 29-Day Program Tests (Ref 24, 25, 33, 35)', () {
    test('calculates exactly 29 wirds for defaultProgram', () {
      final startDate = DateTime(2026, 11, 10);
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );

      expect(wirds.length, equals(29));
      expect(wirds.first.dayNumber, equals(1));
      expect(wirds.last.dayNumber, equals(29));
    });

    test('verifies start and end boundaries of all 29 wirds matching AGENTS.md lines 230-232', () {
      final startDate = DateTime(2026, 11, 10);
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );

      // Day 1: Al-Fatihah 1:1 -> Al-Baqarah 2:141 (pp. 1 - 21)
      expect(wirds[0].startSurahNumber, equals(1));
      expect(wirds[0].startAyahNumber, equals(1));
      expect(wirds[0].endSurahNumber, equals(2));
      expect(wirds[0].endAyahNumber, equals(141));
      expect(wirds[0].startPageNumber, equals(1));
      expect(wirds[0].endPageNumber, equals(21));
      expect(wirds[0].rangeText, equals('من الفاتحة إلى البقرة: ١٤١'));

      // Day 2: Al-Baqarah 2:142 -> 2:252 (pp. 22 - 41)
      expect(wirds[1].startSurahNumber, equals(2));
      expect(wirds[1].startAyahNumber, equals(142));
      expect(wirds[1].endSurahNumber, equals(2));
      expect(wirds[1].endAyahNumber, equals(252));
      expect(wirds[1].startPageNumber, equals(22));
      expect(wirds[1].endPageNumber, equals(41));

      // Day 3: Al-Baqarah 2:253 -> Aal-Imran 3:92 (pp. 42 - 62)
      expect(wirds[2].startSurahNumber, equals(2));
      expect(wirds[2].startAyahNumber, equals(253));
      expect(wirds[2].endSurahNumber, equals(3));
      expect(wirds[2].endAyahNumber, equals(92));
      expect(wirds[2].startPageNumber, equals(42));
      expect(wirds[2].endPageNumber, equals(62));

      // Day 4: Aal-Imran 3:93 -> An-Nisa 4:35
      expect(wirds[3].startSurahNumber, equals(3));
      expect(wirds[3].startAyahNumber, equals(93));
      expect(wirds[3].endSurahNumber, equals(4));
      expect(wirds[3].endAyahNumber, equals(35));

      // Day 5: An-Nisa 4:36 -> end of An-Nisa (4:176)
      expect(wirds[4].startSurahNumber, equals(4));
      expect(wirds[4].startAyahNumber, equals(36));
      expect(wirds[4].endSurahNumber, equals(4));
      expect(wirds[4].endAyahNumber, equals(176));

      // Day 6: Al-Ma'idah (5:1 -> 5:120)
      expect(wirds[5].startSurahNumber, equals(5));
      expect(wirds[5].startAyahNumber, equals(1));
      expect(wirds[5].endSurahNumber, equals(5));
      expect(wirds[5].endAyahNumber, equals(120));
      expect(wirds[5].customTitle, equals('المائدة'));

      // Day 7: Al-An'am (6:1 -> 6:165)
      expect(wirds[6].startSurahNumber, equals(6));
      expect(wirds[6].startAyahNumber, equals(1));
      expect(wirds[6].endSurahNumber, equals(6));
      expect(wirds[6].endAyahNumber, equals(165));
      expect(wirds[6].customTitle, equals('الأنعام'));

      // Day 8: Al-A'raf (7:1 -> 7:206)
      expect(wirds[7].startSurahNumber, equals(7));
      expect(wirds[7].startAyahNumber, equals(1));
      expect(wirds[7].endSurahNumber, equals(7));
      expect(wirds[7].endAyahNumber, equals(206));
      expect(wirds[7].customTitle, equals('الأعراف'));

      // Day 9: Al-Anfal 8:1 -> At-Tawbah 9:72
      expect(wirds[8].startSurahNumber, equals(8));
      expect(wirds[8].startAyahNumber, equals(1));
      expect(wirds[8].endSurahNumber, equals(9));
      expect(wirds[8].endAyahNumber, equals(72));

      // Day 10: At-Tawbah 9:73 -> end of Yunus 10:109
      expect(wirds[9].startSurahNumber, equals(9));
      expect(wirds[9].startAyahNumber, equals(73));
      expect(wirds[9].endSurahNumber, equals(10));
      expect(wirds[9].endAyahNumber, equals(109));

      // Day 11: Hud 11:1 -> Yusuf 12:57
      expect(wirds[10].startSurahNumber, equals(11));
      expect(wirds[10].startAyahNumber, equals(1));
      expect(wirds[10].endSurahNumber, equals(12));
      expect(wirds[10].endAyahNumber, equals(57));

      // Day 12: Yusuf 12:58 -> end of Ibrahim 14:52
      expect(wirds[11].startSurahNumber, equals(12));
      expect(wirds[11].startAyahNumber, equals(58));
      expect(wirds[11].endSurahNumber, equals(14));
      expect(wirds[11].endAyahNumber, equals(52));

      // Day 13: Al-Hijr & An-Nahl (15:1 -> 16:128)
      expect(wirds[12].startSurahNumber, equals(15));
      expect(wirds[12].startAyahNumber, equals(1));
      expect(wirds[12].endSurahNumber, equals(16));
      expect(wirds[12].endAyahNumber, equals(128));
      expect(wirds[12].customTitle, equals('الحجر و النحل'));

      // Day 14: Al-Isra & Al-Kahf (17:1 -> 18:110)
      expect(wirds[13].startSurahNumber, equals(17));
      expect(wirds[13].startAyahNumber, equals(1));
      expect(wirds[13].endSurahNumber, equals(18));
      expect(wirds[13].endAyahNumber, equals(110));
      expect(wirds[13].customTitle, equals('الإسراء و الكهف'));

      // Day 15: Maryam & Ta-Ha (19:1 -> 20:135)
      expect(wirds[14].startSurahNumber, equals(19));
      expect(wirds[14].startAyahNumber, equals(1));
      expect(wirds[14].endSurahNumber, equals(20));
      expect(wirds[14].endAyahNumber, equals(135));
      expect(wirds[14].customTitle, equals('مريم و طه'));

      // Day 16: Al-Anbiya & Al-Hajj (21:1 -> 22:78)
      expect(wirds[15].startSurahNumber, equals(21));
      expect(wirds[15].startAyahNumber, equals(1));
      expect(wirds[15].endSurahNumber, equals(22));
      expect(wirds[15].endAyahNumber, equals(78));
      expect(wirds[15].customTitle, equals('الأنبياء و الحج'));

      // Day 17: Al-Mu'minun & An-Nur (23:1 -> 24:64)
      expect(wirds[16].startSurahNumber, equals(23));
      expect(wirds[16].startAyahNumber, equals(1));
      expect(wirds[16].endSurahNumber, equals(24));
      expect(wirds[16].endAyahNumber, equals(64));
      expect(wirds[16].customTitle, equals('المؤمنون و النور'));

      // Day 18: Al-Furqan & Ash-Shu'ara (25:1 -> 26:227)
      expect(wirds[17].startSurahNumber, equals(25));
      expect(wirds[17].startAyahNumber, equals(1));
      expect(wirds[17].endSurahNumber, equals(26));
      expect(wirds[17].endAyahNumber, equals(227));
      expect(wirds[17].customTitle, equals('الفرقان و الشعراء'));

      // Day 19: An-Naml & Al-Qasas (27:1 -> 28:88)
      expect(wirds[18].startSurahNumber, equals(27));
      expect(wirds[18].startAyahNumber, equals(1));
      expect(wirds[18].endSurahNumber, equals(28));
      expect(wirds[18].endAyahNumber, equals(88));
      expect(wirds[18].customTitle, equals('النمل و القصص'));

      // Day 20: Al-Ankabut, Ar-Rum, Luqman & As-Sajdah (29:1 -> 32:30)
      expect(wirds[19].startSurahNumber, equals(29));
      expect(wirds[19].startAyahNumber, equals(1));
      expect(wirds[19].endSurahNumber, equals(32));
      expect(wirds[19].endAyahNumber, equals(30));
      expect(wirds[19].customTitle, equals('العنكبوت و الروم و لقمان و السجدة'));

      // Day 21: Al-Ahzab, Saba & Fatir (33:1 -> 35:45)
      expect(wirds[20].startSurahNumber, equals(33));
      expect(wirds[20].startAyahNumber, equals(1));
      expect(wirds[20].endSurahNumber, equals(35));
      expect(wirds[20].endAyahNumber, equals(45));
      expect(wirds[20].customTitle, equals('الأحزاب و سبأ و فاطر'));

      // Day 22: Ya-Sin, As-Saffat & Sad (36:1 -> 38:88)
      expect(wirds[21].startSurahNumber, equals(36));
      expect(wirds[21].startAyahNumber, equals(1));
      expect(wirds[21].endSurahNumber, equals(38));
      expect(wirds[21].endAyahNumber, equals(88));
      expect(wirds[21].customTitle, equals('يس و الصافات و ص'));

      // Day 23: Az-Zumar & Ghafir (39:1 -> 40:85)
      expect(wirds[22].startSurahNumber, equals(39));
      expect(wirds[22].startAyahNumber, equals(1));
      expect(wirds[22].endSurahNumber, equals(40));
      expect(wirds[22].endAyahNumber, equals(85));
      expect(wirds[22].customTitle, equals('الزمر و غافر'));

      // Day 24: Fussilat, Ash-Shura, Az-Zukhruf & Ad-Dukhan (41:1 -> 44:59)
      expect(wirds[23].startSurahNumber, equals(41));
      expect(wirds[23].startAyahNumber, equals(1));
      expect(wirds[23].endSurahNumber, equals(44));
      expect(wirds[23].endAyahNumber, equals(59));
      expect(wirds[23].customTitle, equals('فصلت و الشورى و الزخرف و الدخان'));

      // Day 25: Al-Jathiyah, Al-Ahqaf, Muhammad, Al-Fath & Al-Hujurat (45:1 -> 49:18)
      expect(wirds[24].startSurahNumber, equals(45));
      expect(wirds[24].startAyahNumber, equals(1));
      expect(wirds[24].endSurahNumber, equals(49));
      expect(wirds[24].endAyahNumber, equals(18));
      expect(wirds[24].customTitle, equals('الجاثية و الأحقاف و محمد و الفتح و الحجرات'));

      // Day 26: Qaf -> Al-Hadid (50:1 -> 57:29)
      expect(wirds[25].startSurahNumber, equals(50));
      expect(wirds[25].startAyahNumber, equals(1));
      expect(wirds[25].endSurahNumber, equals(57));
      expect(wirds[25].endAyahNumber, equals(29));
      expect(wirds[25].rangeText, equals('من ق إلى الحديد'));

      // Day 27: Al-Mujadila -> At-Tahrim (58:1 -> 66:12)
      expect(wirds[26].startSurahNumber, equals(58));
      expect(wirds[26].startAyahNumber, equals(1));
      expect(wirds[26].endSurahNumber, equals(66));
      expect(wirds[26].endAyahNumber, equals(12));
      expect(wirds[26].rangeText, equals('من المجادلة إلى التحريم'));

      // Day 28: Al-Mulk -> Al-Mursalat (67:1 -> 77:50)
      expect(wirds[27].startSurahNumber, equals(67));
      expect(wirds[27].startAyahNumber, equals(1));
      expect(wirds[27].endSurahNumber, equals(77));
      expect(wirds[27].endAyahNumber, equals(50));
      expect(wirds[27].rangeText, equals('من الملك إلى المرسلات'));

      // Day 29: An-Naba -> An-Nas (78:1 -> 114:6)
      expect(wirds[28].startSurahNumber, equals(78));
      expect(wirds[28].startAyahNumber, equals(1));
      expect(wirds[28].endSurahNumber, equals(114));
      expect(wirds[28].endAyahNumber, equals(6));
      expect(wirds[28].endPageNumber, equals(604));
      expect(wirds[28].rangeText, equals('من النبأ إلى الناس'));
    });

    test('verifies perfect continuity across all consecutive 29 wirds with no gaps', () {
      final startDate = DateTime(2026, 11, 10);
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );

      for (int i = 0; i < wirds.length - 1; i++) {
        final current = wirds[i];
        final next = wirds[i + 1];

        if (current.endSurahNumber == next.startSurahNumber) {
          expect(
            next.startAyahNumber,
            equals(current.endAyahNumber + 1),
            reason: 'Gap between wird ${current.dayNumber} and ${next.dayNumber} in Surah ${current.endSurahNumber}',
          );
        } else {
          expect(
            next.startSurahNumber,
            equals(current.endSurahNumber + 1),
            reason: 'Surah gap between wird ${current.dayNumber} and ${next.dayNumber}',
          );
          expect(next.startAyahNumber, equals(1));
          final expectedLastAyahOfCurrent = metadataService.getVerseCount(current.endSurahNumber);
          expect(
            current.endAyahNumber,
            equals(expectedLastAyahOfCurrent),
            reason: 'Wird ${current.dayNumber} did not end at last verse of Surah ${current.endSurahNumber}',
          );
        }
      }
    });

    test('startFromWird marks preceding wirds as completed and aligns schedule', () {
      final startDate = DateTime(2026, 11, 10);
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
        startWirdNumber: 4,
      );

      expect(wirds[0].isCompleted, isTrue);
      expect(wirds[1].isCompleted, isTrue);
      expect(wirds[2].isCompleted, isTrue);

      expect(wirds[3].isCompleted, isFalse);
      expect(wirds[3].dayNumber, equals(4));
      expect(wirds[3].scheduledDate, equals(startDate));

      expect(wirds[4].isCompleted, isFalse);
      expect(wirds[4].dayNumber, equals(5));
      expect(wirds[4].scheduledDate, equals(DateTime(2026, 11, 11)));
    });
  });

  group('KhatmaWirdCalculator Parts & Quarters Programs Tests', () {
    test('30-day program divides into 30 consecutive Juzs', () {
      final startDate = DateTime(2026, 11, 10);
      final program30 = KhatmaProgram.findById('parts_30')!;
      final wirds = calculator.calculateWirds(
        program: program30,
        startDate: startDate,
      );

      expect(wirds.length, equals(30));
      expect(wirds.first.customTitle, equals('الجزء الأول'));
      expect(wirds.last.customTitle, equals('الجزء الثلاثون'));
      expect(wirds.first.startPageNumber, equals(1));
      expect(wirds.last.endPageNumber, equals(604));
    });

    test('240-day quarters program generates 240 portions', () {
      final startDate = DateTime(2026, 11, 10);
      final program240 = KhatmaProgram.findById('quarters_240')!;
      final wirds = calculator.calculateWirds(
        program: program240,
        startDate: startDate,
      );

      expect(wirds.length, equals(240));
      expect(wirds.first.startSurahNumber, equals(1));
      expect(wirds.first.startAyahNumber, equals(1));
      expect(wirds.last.endSurahNumber, equals(114));
      expect(wirds.last.endAyahNumber, equals(6));
    });
  });

  group('KhatmaWirdCalculator Start-Position Calculation Tests (TASK 6.04)', () {
    const program29 = KhatmaProgram.defaultProgram;
    final program30 = KhatmaProgram.findById('parts_30')!;

    test('validates Quran verse positions correctly', () {
      expect(calculator.isValidAyahPosition(1, 1), isTrue);
      expect(calculator.isValidAyahPosition(2, 286), isTrue);
      expect(calculator.isValidAyahPosition(114, 6), isTrue);

      expect(calculator.isValidAyahPosition(0, 1), isFalse);
      expect(calculator.isValidAyahPosition(115, 1), isFalse);
      expect(calculator.isValidAyahPosition(1, 0), isFalse);
      expect(calculator.isValidAyahPosition(2, 287), isFalse);
    });

    test('validates Mushaf page numbers correctly', () {
      expect(calculator.isValidPagePosition(1), isTrue);
      expect(calculator.isValidPagePosition(604), isTrue);
      expect(calculator.isValidPagePosition(0), isFalse);
      expect(calculator.isValidPagePosition(605), isFalse);
    });

    test('calculates exact wird number on Surah and Ayah boundaries in 29-day program', () {
      // First verse of Quran -> Wird 1
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 1, ayahNumber: 1), equals(1));
      // End of Wird 1 (2:141) -> Wird 1
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 141), equals(1));

      // Start of Wird 2 (2:142) -> Wird 2
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 142), equals(2));
      // Mid Wird 2 (2:200) -> Wird 2
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 200), equals(2));
      // End of Wird 2 (2:252) -> Wird 2
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 252), equals(2));

      // Start of Wird 3 (2:253) -> Wird 3
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 253), equals(3));
      // End of Wird 3 (3:92) -> Wird 3
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 3, ayahNumber: 92), equals(3));

      // Start of Wird 4 (3:93) -> Wird 4
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 3, ayahNumber: 93), equals(4));
      // End of Wird 4 (4:35) -> Wird 4
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 4, ayahNumber: 35), equals(4));

      // Start of Wird 5 (4:36) -> Wird 5
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 4, ayahNumber: 36), equals(5));
      // End of Wird 5 (4:176) -> Wird 5
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 4, ayahNumber: 176), equals(5));

      // Start of Wird 6 (5:1) -> Wird 6
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 5, ayahNumber: 1), equals(6));

      // Last verse of Quran (114:6) -> Wird 29
      expect(calculator.findWirdNumberForAyah(program: program29, surahNumber: 114, ayahNumber: 6), equals(29));
    });

    test('calculates exact wird number on Juz boundaries in 30-day program', () {
      // Juz 1 -> Wird 1
      expect(calculator.findWirdNumberForAyah(program: program30, surahNumber: 1, ayahNumber: 1), equals(1));
      // Juz 2 (starts at 2:142) -> Wird 2
      expect(calculator.findWirdNumberForAyah(program: program30, surahNumber: 2, ayahNumber: 142), equals(2));
      // Juz 30 (starts at 78:1) -> Wird 30
      expect(calculator.findWirdNumberForAyah(program: program30, surahNumber: 78, ayahNumber: 1), equals(30));
      // Last verse (114:6) -> Wird 30
      expect(calculator.findWirdNumberForAyah(program: program30, surahNumber: 114, ayahNumber: 6), equals(30));
    });

    test('calculates exact wird number from page boundaries', () {
      expect(calculator.findWirdNumberForPage(program: program29, pageNumber: 1), equals(1));
      // Page 22 (starts at 2:142) -> Wird 2
      expect(calculator.findWirdNumberForPage(program: program29, pageNumber: 22), equals(2));
      // Page 604 -> Wird 29
      expect(calculator.findWirdNumberForPage(program: program29, pageNumber: 604), equals(29));
    });

    test('throws ArgumentError on invalid surah, ayah, or page', () {
      expect(
        () => calculator.findWirdNumberForAyah(program: program29, surahNumber: 0, ayahNumber: 1),
        throwsArgumentError,
      );
      expect(
        () => calculator.findWirdNumberForAyah(program: program29, surahNumber: 115, ayahNumber: 1),
        throwsArgumentError,
      );
      expect(
        () => calculator.findWirdNumberForAyah(program: program29, surahNumber: 2, ayahNumber: 999),
        throwsArgumentError,
      );
      expect(
        () => calculator.findWirdNumberForPage(program: program29, pageNumber: 0),
        throwsArgumentError,
      );
      expect(
        () => calculator.findWirdNumberForPage(program: program29, pageNumber: 605),
        throwsArgumentError,
      );
    });
  });
}
