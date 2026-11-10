import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_program_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhatmaProgramRules Mathematical & Linguistic Derivation Tests', () {
    test('partsAndQuartersDaysOrder contains exactly 11 programs in descending order', () {
      expect(
        KhatmaProgramRules.partsAndQuartersDaysOrder,
        equals([240, 120, 80, 60, 40, 30, 20, 15, 10, 6, 3]),
      );
    });

    test('all 11 parts and quarters programs divide 240 quarters with zero remainder', () {
      for (final days in KhatmaProgramRules.partsAndQuartersDaysOrder) {
        expect(
          240 % days,
          equals(0),
          reason: '$days days must evenly divide 240 quarters',
        );
        expect(
          KhatmaProgramRules.isValid(
            totalDays: days,
            category: KhatmaProgramCategory.partsAndQuarters,
          ),
          isTrue,
        );
      }
    });

    test('derives exact title and subtitle matching Reference 32 for all 11 programs', () {
      final expected = <int, Map<String, String>>{
        240: {'title': 'ختمة ٢٤٠ يوما', 'sub': 'الورد اليومي: ربع'},
        120: {'title': 'ختمة ١٢٠ يوما', 'sub': 'الورد اليومي: ربعان'},
        80: {'title': 'ختمة ٨٠ يوما', 'sub': 'الورد اليومي: ٣ أرباع'},
        60: {'title': 'ختمة ٦٠ يوما', 'sub': 'الورد اليومي: حزب'},
        40: {'title': 'ختمة ٤٠ يوما', 'sub': 'الورد اليومي: حزب ونصف'},
        30: {'title': 'ختمة ٣٠ يوما', 'sub': 'الورد اليومي: جزء'},
        20: {'title': 'ختمة ٢٠ يوما', 'sub': 'الورد اليومي: جزء ونصف'},
        15: {'title': 'ختمة ١٥ يوما', 'sub': 'الورد اليومي: جزءان'},
        10: {'title': 'ختمة ١٠ أيام', 'sub': 'الورد اليومي: ٣ أجزاء'},
        6: {'title': 'ختمة ٦ أيام', 'sub': 'الورد اليومي: ٥ أجزاء'},
        3: {'title': 'ختمة ٣ أيام', 'sub': 'الورد اليومي: ١٠ أجزاء'},
      };

      for (final entry in expected.entries) {
        final days = entry.key;
        final title = KhatmaProgramRules.deriveTitle(
          totalDays: days,
          category: KhatmaProgramCategory.partsAndQuarters,
        );
        final sub = KhatmaProgramRules.deriveSubtitle(
          totalDays: days,
          category: KhatmaProgramCategory.partsAndQuarters,
        );

        expect(title, equals(entry.value['title']));
        expect(sub, equals(entry.value['sub']));
      }
    });

    test('derives exact title and subtitle matching Reference 09 for meaning programs', () {
      // 60 days
      expect(
        KhatmaProgramRules.deriveTitle(
          totalDays: 60,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('ختمة شهرين (٦٠ يومًا)'),
      );
      expect(
        KhatmaProgramRules.deriveSubtitle(
          totalDays: 60,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('الورد اليومي: ١٠ صفحات تقريبًا'),
      );

      // 29 days
      expect(
        KhatmaProgramRules.deriveTitle(
          totalDays: 29,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('ختمة شهر (٢٩ يومًا)'),
      );
      expect(
        KhatmaProgramRules.deriveSubtitle(
          totalDays: 29,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('الورد اليومي: ٢١ صفحة تقريبًا'),
      );

      // 7 days
      expect(
        KhatmaProgramRules.deriveTitle(
          totalDays: 7,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('ختمة أسبوع (٧ أيام)'),
      );
      expect(
        KhatmaProgramRules.deriveSubtitle(
          totalDays: 7,
          category: KhatmaProgramCategory.meaning,
        ),
        equals('الورد اليومي: ٥ أجزاء تقريبًا'),
      );
    });

    test('boundary validation rejects invalid durations and unaligned divisions', () {
      // Out of bounds
      expect(
        KhatmaProgramRules.isValid(
          totalDays: 2,
          category: KhatmaProgramCategory.partsAndQuarters,
        ),
        isFalse,
      );
      expect(
        KhatmaProgramRules.isValid(
          totalDays: 241,
          category: KhatmaProgramCategory.partsAndQuarters,
        ),
        isFalse,
      );

      // Does not divide 240
      expect(
        KhatmaProgramRules.isValid(
          totalDays: 50,
          category: KhatmaProgramCategory.partsAndQuarters,
        ),
        isFalse,
      );
      expect(
        KhatmaProgramRules.isValid(
          totalDays: 35,
          category: KhatmaProgramCategory.partsAndQuarters,
        ),
        isFalse,
      );

      // Meaning category strictly permits only 60, 29, 7
      expect(
        KhatmaProgramRules.isValid(
          totalDays: 30,
          category: KhatmaProgramCategory.meaning,
        ),
        isFalse,
      );
    });

    test('KhatmaProgram.fromRules creates program with derived titles and subtitles', () {
      final prog240 = KhatmaProgram.fromRules(
        id: 'quarters_240',
        totalDays: 240,
        category: KhatmaProgramCategory.partsAndQuarters,
      );
      expect(prog240.title, equals('ختمة ٢٤٠ يوما'));
      expect(prog240.subtitle, equals('الورد اليومي: ربع'));

      final prog10 = KhatmaProgram.fromRules(
        id: 'parts_10',
        totalDays: 10,
        category: KhatmaProgramCategory.partsAndQuarters,
      );
      expect(prog10.title, equals('ختمة ١٠ أيام'));
      expect(prog10.subtitle, equals('الورد اليومي: ٣ أجزاء'));
    });

    test('KhatmaProgram.partsAndQuartersPrograms matches exact order of Screenshot 32', () {
      final days = KhatmaProgram.partsAndQuartersPrograms
          .map((p) => p.totalDays)
          .toList();
      expect(days, equals([240, 120, 80, 60, 40, 30, 20, 15, 10, 6, 3]));
    });
  });
}

