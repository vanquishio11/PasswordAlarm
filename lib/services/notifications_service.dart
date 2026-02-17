import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(iOS: iosInit);

    await _plugin.initialize(initSettings);
  }

  /// Schedules a daily alarm at the given local time.
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
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
