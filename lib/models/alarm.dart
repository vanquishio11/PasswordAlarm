import 'dart:convert';

class Alarm {
  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.isAm,
    required this.enabled,
    required this.label,
    required this.soundId,
    required this.password,
  });

  final String id;
  final int hour; // 1-12
  final int minute; // 0-59
  final bool isAm;
  bool enabled;

  final String label;
  final String soundId;
  final String password;

  String formatTime() {
    final m = minute.toString().padLeft(2, '0');
    return '$hour:$m';
  }

  String amPm() => isAm ? 'AM' : 'PM';

  /// Convert stored 12-hour time to a local DateTime (today) at that time.
  DateTime toLocalDateTimeToday() {
    int h24;
    if (isAm) {
      h24 = (hour == 12) ? 0 : hour;
    } else {
      h24 = (hour == 12) ? 12 : hour + 12;
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h24, minute);
  }

  /// Stable int id for notifications derived from string id.
  int notificationId() => _fnv1a32(id);

  static int _fnv1a32(String input) {
    const int fnvPrime = 16777619;
    int hash = 2166136261;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    // flutter_local_notifications expects a signed 32-bit-ish int; keep it positive.
    return hash & 0x7FFFFFFF;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'isAm': isAm,
        'enabled': enabled,
        'label': label,
        'soundId': soundId,
        'password': password,
      };

  static Alarm fromMap(Map<String, dynamic> map) => Alarm(
        id: map['id'] as String,
        hour: map['hour'] as int,
        minute: map['minute'] as int,
        isAm: map['isAm'] as bool,
        enabled: map['enabled'] as bool,
        label: (map['label'] as String?) ?? '',
        soundId: (map['soundId'] as String?) ?? 'radar',
        password: (map['password'] as String?) ?? '',
      );

  static List<Alarm> listFromJson(String jsonStr) {
    final raw = json.decode(jsonStr) as List<dynamic>;
    return raw.map((e) => Alarm.fromMap(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Alarm> alarms) {
    return json.encode(alarms.map((a) => a.toMap()).toList());
  }
}
