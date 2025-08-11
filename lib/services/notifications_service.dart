// lib/services/notifications_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await _plugin.cancel(1001);
  }

  static Future<void> init() async {
    if (_initialized || kIsWeb) return; // no-op on web
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macInit = DarwinInitializationSettings(); // required for macOS

    const init = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: macInit,
    );

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (NotificationResponse r) {},
    );
    _initialized = true;
  }

  static Future<bool> _requestPerms() async {
    if (kIsWeb) return false;
    final android = await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = await _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, sound: true, badge: true);
    return true;
  }

  static Future<void> scheduleDailyReading({
    TimeOfDay at = const TimeOfDay(hour: 7, minute: 0),
  }) async {
    if (kIsWeb) throw UnsupportedError('Notifications not supported on web');
    await _requestPerms();

    final now = tz.TZDateTime.now(tz.local);
    final first = tz.TZDateTime(tz.local, now.year, now.month, now.day, at.hour, at.minute);
    final next = first.isBefore(now) ? first.add(const Duration(days: 1)) : first;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reading', 'Daily Reading',
        channelDescription: 'Daily reading reminder',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      1001,
      'Daily Reading',
      'Open today’s reading',
      next,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleTestInSeconds(int seconds) async {
    if (kIsWeb) throw UnsupportedError('Notifications not supported on web');
    await _requestPerms();

    const details = NotificationDetails(
      android: AndroidNotificationDetails('tests', 'Tests'),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      2001,
      'Test Reminder',
      'This is a test notification',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
