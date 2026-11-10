import 'dart:io';

import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Production implementation of [KhatmaReminderService] using `flutter_local_notifications`
/// and the `timezone` package.
///
/// Features:
/// - Inexact battery-friendly daily scheduling (`AndroidScheduleMode.inexactAllowWhileIdle`).
/// - Android 13+ and iOS permission workflows.
/// - Next instance calculation accounting for time transitions and already-elapsed hours.
/// - Notification response dispatch to deep-link to the active wird.
class KhatmaReminderServiceImpl implements KhatmaReminderService {
  static const int dailyReminderNotificationId = 7001;
  static const String channelId = 'khatma_daily_wird_channel';
  static const String channelName = 'تذكير الورد اليومي';
  static const String channelDescription =
      'تنبيه يومي لقراءة الورد القرآني المحدد في الختمة';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  void Function(String? payload)? _onTapCallback;

  KhatmaReminderServiceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> init({void Function(String? payload)? onNotificationTap}) async {
    if (_isInitialized) {
      _onTapCallback = onNotificationTap;
      return;
    }

    _onTapCallback = onNotificationTap;

    // 1. Initialize timezone database
    tz_data.initializeTimeZones();
    _configureLocalTimeZone();

    // 2. Configure platform-specific initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onTapCallback?.call(response.payload);
      },
    );

    _isInitialized = true;

    // 3. Check if app was launched via notification click
    try {
      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse?.payload != null) {
        _onTapCallback?.call(launchDetails!.notificationResponse!.payload);
      }
    } catch (_) {}
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImpl != null) {
          final granted = await androidImpl.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImpl != null) {
          final granted = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
    } catch (_) {}
    return true;
  }

  @override
  Future<bool> hasPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImpl != null) {
          final enabled = await androidImpl.areNotificationsEnabled();
          return enabled ?? false;
        }
      }
    } catch (_) {}
    return true;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    await init(onNotificationTap: _onTapCallback);

    final scheduledDate = computeNextInstance(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      dailyReminderNotificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  @override
  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(dailyReminderNotificationId);
  }

  /// Computes the next daily [tz.TZDateTime] for the target [hour] and [minute].
  ///
  /// If the target time today is already in the past, schedules for tomorrow.
  static tz.TZDateTime computeNextInstance(
    int hour,
    int minute, {
    tz.TZDateTime? now,
    tz.Location? location,
  }) {
    final effectiveLocation = location ?? tz.local;
    final current = now ?? tz.TZDateTime.now(effectiveLocation);

    var scheduledDate = tz.TZDateTime(
      effectiveLocation,
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(current)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Configures local timezone safely, falling back to UTC / local offset if needed.
  void _configureLocalTimeZone() {
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback: tz.local remains initialized or defaults safely
    }
  }
}

