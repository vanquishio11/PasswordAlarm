import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_alarm/models/alarm.dart';

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
}
