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
