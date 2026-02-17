class AlarmSound {
  const AlarmSound({required this.id, required this.name, required this.desc});

  final String id;
  final String name;
  final String desc;

  static const List<AlarmSound> all = [
    AlarmSound(id: 'radar', name: 'Radar', desc: 'Classic radar beep'),
    AlarmSound(id: 'chime', name: 'Chime', desc: 'Gentle bell tones'),
    AlarmSound(id: 'digital', name: 'Digital', desc: 'Modern electronic tone'),
    AlarmSound(id: 'gentle', name: 'Gentle', desc: 'Soft wake-up melody'),
    AlarmSound(id: 'rooster', name: 'Rooster', desc: 'Morning rooster call'),
  ];

  static AlarmSound byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);
}
