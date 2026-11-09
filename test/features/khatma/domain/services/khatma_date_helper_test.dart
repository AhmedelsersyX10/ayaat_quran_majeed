import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Khatma Relative Day Labels Tests (Screens 26 & 31)', () {
    KhatmaWird createWirdWithScheduledDate(DateTime scheduledDate) {
      return KhatmaWird(
        dayNumber: 1,
        scheduledDate: scheduledDate,
        startSurahNumber: 1,
        startAyahNumber: 1,
        endSurahNumber: 1,
        endAyahNumber: 7,
        startPageNumber: 1,
        endPageNumber: 1,
        startSurahName: 'الفاتحة',
        endSurahName: 'الفاتحة',
        firstVerseText: 'بِسْمِ ٱللَّهِ',
        lastVerseText: 'غَيْرِ ٱلْمَغْضُوبِ',
        rangeText: 'الفاتحة',
      );
    }

    test('same day returns اليوم matching reference screenshot 31', () {
      final today = DateTime(2026, 11, 10, 14, 30);
      final scheduled = DateTime(2026, 11, 10, 0, 0);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('اليوم'));
    });

    test('tomorrow returns غداً', () {
      final today = DateTime(2026, 11, 10, 9, 0);
      final scheduled = DateTime(2026, 11, 11, 0, 0);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('غداً'));
    });

    test('scheduled in 2 days returns بعد يومين matching reference screenshot 26', () {
      final today = DateTime(2026, 11, 10, 10, 0);
      final scheduled = DateTime(2026, 11, 12, 0, 0);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('بعد يومين'));
    });

    test('scheduled in 3 to 10 days uses Arabic plural أيام', () {
      final today = DateTime(2026, 11, 10);
      final scheduled3 = DateTime(2026, 11, 13);
      final scheduled5 = DateTime(2026, 11, 15);
      final scheduled10 = DateTime(2026, 11, 20);

      expect(createWirdWithScheduledDate(scheduled3).relativeDayLabel(today), equals('بعد ٣ أيام'));
      expect(createWirdWithScheduledDate(scheduled5).relativeDayLabel(today), equals('بعد ٥ أيام'));
      expect(createWirdWithScheduledDate(scheduled10).relativeDayLabel(today), equals('بعد ١٠ أيام'));
    });

    test('scheduled in more than 10 days uses Arabic singular يوماً', () {
      final today = DateTime(2026, 11, 10);
      final scheduled15 = DateTime(2026, 11, 25);

      expect(createWirdWithScheduledDate(scheduled15).relativeDayLabel(today), equals('بعد ١٥ يوماً'));
    });

    test('yesterday returns أمس', () {
      final today = DateTime(2026, 11, 10, 20, 0);
      final scheduled = DateTime(2026, 11, 9, 0, 0);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('أمس'));
    });

    test('2 days ago returns قبل يومين', () {
      final today = DateTime(2026, 11, 10);
      final scheduled = DateTime(2026, 11, 8);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('قبل يومين'));
    });

    test('3 to 10 days ago returns قبل X أيام', () {
      final today = DateTime(2026, 11, 10);
      final scheduled = DateTime(2026, 11, 6);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('قبل ٤ أيام'));
    });

    test('more than 10 days ago returns قبل X يوماً', () {
      final today = DateTime(2026, 11, 25);
      final scheduled = DateTime(2026, 11, 10);

      final wird = createWirdWithScheduledDate(scheduled);
      expect(wird.relativeDayLabel(today), equals('قبل ١٥ يوماً'));
    });
  });
}

