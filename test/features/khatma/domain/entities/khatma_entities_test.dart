import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhatmaProgram Entity Tests', () {
    test('defaultProgram matches reference 29-day meaning program', () {
      const p = KhatmaProgram.defaultProgram;
      expect(p.id, equals('meaning_29'));
      expect(p.title, equals('ختمة شهر (٢٩ يومًا)'));
      expect(p.totalDays, equals(29));
      expect(p.category, equals(KhatmaProgramCategory.suggested));
    });

    test('findById returns matching program', () {
      final p1 = KhatmaProgram.findById('meaning_29');
      expect(p1, isNotNull);
      expect(p1?.totalDays, equals(29));

      final p2 = KhatmaProgram.findById('parts_30');
      expect(p2, isNotNull);
      expect(p2?.totalDays, equals(30));

      final p3 = KhatmaProgram.findById('quarters_240');
      expect(p3, isNotNull);
      expect(p3?.totalDays, equals(240));

      final pNull = KhatmaProgram.findById('unknown_id');
      expect(pNull, isNull);
    });
  });

  group('KhatmaWird Entity Tests', () {
    test('dayTitle and displayTitle format correctly', () {
      final wird1 = KhatmaWird(
        dayNumber: 1,
        scheduledDate: DateTime(2026, 11, 10),
        startSurahNumber: 1,
        startAyahNumber: 1,
        endSurahNumber: 2,
        endAyahNumber: 141,
        startPageNumber: 1,
        endPageNumber: 21,
        startSurahName: 'الفاتحة',
        endSurahName: 'البقرة',
        firstVerseText: 'بِسْمِ ٱللَّهِ',
        lastVerseText: 'تِلْكَ أُمَّةٌ',
        rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      );

      expect(wird1.dayTitle, equals('ورد اليوم ١'));
      expect(wird1.displayTitle, equals('من الفاتحة إلى البقرة: ١٤١'));

      final wird6 = KhatmaWird(
        dayNumber: 6,
        scheduledDate: DateTime(2026, 11, 15),
        startSurahNumber: 5,
        startAyahNumber: 1,
        endSurahNumber: 5,
        endAyahNumber: 120,
        startPageNumber: 106,
        endPageNumber: 127,
        startSurahName: 'المائدة',
        endSurahName: 'المائدة',
        firstVerseText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟',
        lastVerseText: 'لِلَّهِ مُلْكُ ٱلسَّمَـٰوَٰتِ',
        customTitle: 'المائدة',
        rangeText: 'المائدة',
      );

      expect(wird6.dayTitle, equals('ورد اليوم ٦'));
      expect(wird6.displayTitle, equals('المائدة'));
    });

    test('copyWith updates properties correctly', () {
      final wird = KhatmaWird(
        dayNumber: 1,
        scheduledDate: DateTime(2026, 11, 10),
        startSurahNumber: 1,
        startAyahNumber: 1,
        endSurahNumber: 2,
        endAyahNumber: 141,
        startPageNumber: 1,
        endPageNumber: 21,
        startSurahName: 'الفاتحة',
        endSurahName: 'البقرة',
        firstVerseText: 'بِسْمِ ٱللَّهِ',
        lastVerseText: 'تِلْكَ أُمَّةٌ',
        rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      );

      final completedDate = DateTime(2026, 11, 10, 18, 0);
      final updated = wird.copyWith(isCompleted: true, completedAt: completedDate);

      expect(updated.isCompleted, isTrue);
      expect(updated.completedAt, equals(completedDate));
      expect(updated.dayNumber, equals(1));
    });
  });

  group('Khatma Aggregate Entity Tests', () {
    final wird1 = KhatmaWird(
      dayNumber: 1,
      scheduledDate: DateTime(2026, 11, 10),
      startSurahNumber: 1,
      startAyahNumber: 1,
      endSurahNumber: 2,
      endAyahNumber: 141,
      startPageNumber: 1,
      endPageNumber: 21,
      startSurahName: 'الفاتحة',
      endSurahName: 'البقرة',
      firstVerseText: 'بِسْمِ ٱللَّهِ',
      lastVerseText: 'تِلْكَ أُمَّةٌ',
      rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      isCompleted: true,
    );

    final wird2 = KhatmaWird(
      dayNumber: 2,
      scheduledDate: DateTime(2026, 11, 11),
      startSurahNumber: 2,
      startAyahNumber: 142,
      endSurahNumber: 2,
      endAyahNumber: 252,
      startPageNumber: 22,
      endPageNumber: 42,
      startSurahName: 'البقرة',
      endSurahName: 'البقرة',
      firstVerseText: 'سَيَقُولُ',
      lastVerseText: 'تِلْكَ ءَايَـٰتُ',
      rangeText: 'من البقرة: ١٤٢ إلى البقرة: ٢٥٢',
      isCompleted: false,
    );

    test('currentWird returns first uncompleted wird', () {
      final khatma = Khatma(
        id: 'test_khatma',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 2,
        startDate: DateTime(2026, 11, 10),
        wirds: [wird1, wird2],
        completedWirdsCount: 1,
        createdAt: DateTime(2026, 11, 10),
      );

      expect(khatma.currentWird, equals(wird2));
      expect(khatma.progress, equals(0.5));
      expect(khatma.remainingDays, equals(1));
    });

    test('currentWird returns last wird if all completed', () {
      final completedWird2 = wird2.copyWith(isCompleted: true);
      final khatma = Khatma(
        id: 'test_khatma',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 2,
        startDate: DateTime(2026, 11, 10),
        wirds: [wird1, completedWird2],
        completedWirdsCount: 2,
        isCompleted: true,
        createdAt: DateTime(2026, 11, 10),
      );

      expect(khatma.currentWird, equals(completedWird2));
      expect(khatma.progress, equals(1.0));
      expect(khatma.remainingDays, equals(0));
    });

    test('formattedReminderTime formats 19:00 as ٧:٠٠ م', () {
      final khatma = Khatma(
        id: 'test_khatma',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 2,
        startDate: DateTime(2026, 11, 10),
        wirds: [wird1, wird2],
        reminderTimeHour: 19,
        reminderTimeMinute: 0,
        createdAt: DateTime(2026, 11, 10),
      );

      expect(khatma.formattedReminderTime, equals('٧:٠٠ م'));
    });
  });
}
