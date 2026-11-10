import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_reminder_service.dart';

/// Test double implementing [KhatmaReminderService] with tracking for testing.
class FakeKhatmaReminderService implements KhatmaReminderService {
  int initCallCount = 0;
  void Function(String? payload)? onNotificationTapCallback;

  bool permissionToReturn = true;
  int requestPermissionCallCount = 0;
  int hasPermissionCallCount = 0;

  int scheduleCallCount = 0;
  int? lastScheduledHour;
  int? lastScheduledMinute;
  String? lastScheduledTitle;
  String? lastScheduledBody;
  String? lastScheduledPayload;

  int cancelCallCount = 0;

  @override
  Future<void> init({void Function(String? payload)? onNotificationTap}) async {
    initCallCount++;
    onNotificationTapCallback = onNotificationTap;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    return permissionToReturn;
  }

  @override
  Future<bool> hasPermission() async {
    hasPermissionCallCount++;
    return permissionToReturn;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduleCallCount++;
    lastScheduledHour = hour;
    lastScheduledMinute = minute;
    lastScheduledTitle = title;
    lastScheduledBody = body;
    lastScheduledPayload = payload;
  }

  @override
  Future<void> cancelDailyReminder() async {
    cancelCallCount++;
    lastScheduledHour = null;
    lastScheduledMinute = null;
    lastScheduledTitle = null;
    lastScheduledBody = null;
    lastScheduledPayload = null;
  }

  void simulateNotificationTap(String payload) {
    onNotificationTapCallback?.call(payload);
  }

  void reset() {
    initCallCount = 0;
    onNotificationTapCallback = null;
    permissionToReturn = true;
    requestPermissionCallCount = 0;
    hasPermissionCallCount = 0;
    scheduleCallCount = 0;
    lastScheduledHour = null;
    lastScheduledMinute = null;
    lastScheduledTitle = null;
    lastScheduledBody = null;
    lastScheduledPayload = null;
    cancelCallCount = 0;
  }
}

