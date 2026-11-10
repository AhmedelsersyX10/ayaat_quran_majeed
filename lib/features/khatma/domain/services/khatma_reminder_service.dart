/// Pure Dart domain contract for scheduling and managing daily Khatma reminders.
///
/// Follows Clean Architecture — zero Flutter framework imports.
abstract class KhatmaReminderService {
  /// Initializes the reminder service, notification channels, and registers the tap callback.
  Future<void> init({void Function(String? payload)? onNotificationTap});

  /// Requests notification permission from the host platform (Android 13+, iOS).
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission();

  /// Checks whether notification permission is currently granted.
  Future<bool> hasPermission();

  /// Schedules a recurring daily local reminder at the specified [hour] (0-23) and [minute] (0-59).
  ///
  /// Uses inexact battery-friendly scheduling (`inexactAllowWhileIdle`) without requiring
  /// restricted exact alarm permissions.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  });

  /// Cancels the scheduled daily Khatma reminder notification if active.
  Future<void> cancelDailyReminder();
}

