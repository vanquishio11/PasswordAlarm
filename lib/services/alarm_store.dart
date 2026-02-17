import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_alarm/models/alarm.dart';
import 'package:password_alarm/services/notifications_service.dart';

class AlarmStore {
  static const _key = 'alarms_v1';

  Future<List<Alarm>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];
    try {
      return Alarm.listFromJson(jsonStr);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Alarm.listToJson(alarms));
  }

  Future<List<Alarm>> addAlarm(Alarm alarm) async {
    final alarms = await load();
    alarms.add(alarm);
    await save(alarms);

    if (alarm.enabled) {
      await NotificationsService.instance.scheduleDailyAlarm(
        id: alarm.notificationId(),
        whenLocal: alarm.toLocalDateTimeToday(),
        title: "Alarm",
        body: alarm.label.trim().isEmpty ? "Password Alarm" : alarm.label.trim(),
      );
    }
    return alarms;
  }

  Future<List<Alarm>> upsertAlarm(Alarm alarm) async {
    final alarms = await load();
    final idx = alarms.indexWhere((a) => a.id == alarm.id);
    if (idx >= 0) {
      alarms[idx] = alarm;
    } else {
      alarms.add(alarm);
    }
    await save(alarms);

    // Reschedule based on enabled
    await NotificationsService.instance.cancel(alarm.notificationId());
    if (alarm.enabled) {
      await NotificationsService.instance.scheduleDailyAlarm(
        id: alarm.notificationId(),
        whenLocal: alarm.toLocalDateTimeToday(),
        title: "Alarm",
        body: alarm.label.trim().isEmpty ? "Password Alarm" : alarm.label.trim(),
      );
    }
    return alarms;
  }

  Future<List<Alarm>> deleteAlarm(String alarmId) async {
    final alarms = await load();
    final alarm = alarms.where((a) => a.id == alarmId).toList().firstOrNull;
    alarms.removeWhere((a) => a.id == alarmId);
    await save(alarms);

    if (alarm != null) {
      await NotificationsService.instance.cancel(alarm.notificationId());
    }
    return alarms;
  }
}

// tiny helper (keeps you from importing collection package)
extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
