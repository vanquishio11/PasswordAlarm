import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // iOS can behave like UTC unless we explicitly set the local location.
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Explicit permission request is more reliable across iOS versions.
    await _plugin
        .resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules the next occurrence of the alarm time (today or tomorrow).
  ///
  /// Note: this is intentionally a one-shot schedule (not repeating), which
  /// matches typical "set an alarm" behavior.
  Future<void> scheduleDailyAlarm({
    required int id,
    required DateTime whenLocal,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var when = DateTime(
      now.year,
      now.month,
      now.day,
      whenLocal.hour,
      whenLocal.minute,
    );

    // If time already passed today, schedule for tomorrow
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
