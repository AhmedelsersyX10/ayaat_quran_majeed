import 'package:ayaat_quran_majeed/features/khatma/data/services/khatma_reminder_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('KhatmaReminderServiceImpl.computeNextInstance', () {
    test('schedules for today if target time is in the future', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026, 11, 10, 14, 0); // 2:00 PM
      final result = KhatmaReminderServiceImpl.computeNextInstance(
        19, // 7:00 PM (future)
        0,
        now: now,
        location: location,
      );

      expect(result.year, 2026);
      expect(result.month, 11);
      expect(result.day, 10);
      expect(result.hour, 19);
      expect(result.minute, 0);
    });

    test('schedules for tomorrow if target time today is already in the past', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026, 11, 10, 20, 30); // 8:30 PM
      final result = KhatmaReminderServiceImpl.computeNextInstance(
        19, // 7:00 PM (past)
        0,
        now: now,
        location: location,
      );

      expect(result.year, 2026);
      expect(result.month, 11);
      expect(result.day, 11); // next day
      expect(result.hour, 19);
      expect(result.minute, 0);
    });

    test('schedules for tomorrow if target time is exactly now', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026, 11, 10, 19, 0, 1);
      final result = KhatmaReminderServiceImpl.computeNextInstance(
        19,
        0,
        now: now,
        location: location,
      );

      expect(result.day, 11);
      expect(result.hour, 19);
      expect(result.minute, 0);
    });

    test('preserves hour and minute across month transitions', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026, 11, 30, 22, 0);
      final result = KhatmaReminderServiceImpl.computeNextInstance(
        7,
        30,
        now: now,
        location: location,
      );

      expect(result.year, 2026);
      expect(result.month, 12);
      expect(result.day, 1);
      expect(result.hour, 7);
      expect(result.minute, 30);
    });
  });
}

