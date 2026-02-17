import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:password_alarm/models/alarm.dart';
import 'package:password_alarm/screens/new_alarm_sheet.dart';
import 'package:password_alarm/screens/ringing_screen.dart';
import 'package:password_alarm/services/alarm_store.dart';
import 'package:password_alarm/theme/app_theme.dart';
import 'package:password_alarm/widgets/alarm_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = AlarmStore();
  final List<Alarm> _alarms = [];
  Timer? _clockTimer;

  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
      _checkFires();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final loaded = await _store.load();
    setState(() => _alarms
      ..clear()
      ..addAll(loaded));
  }

  Future<void> _persist() async => _store.save(_alarms);

  Future<void> _openNewAlarm() async {
    final created = await showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewAlarmSheet(),
    );

    if (created == null) return;
    setState(() => _alarms.insert(0, created));
    await _persist();
  }

  void _checkFires() {
    for (final alarm in _alarms) {
      if (!alarm.enabled) continue;

      final now = _now;
      final nowHour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final isAmNow = now.hour < 12;

      if (nowHour12 == alarm.hour &&
          now.minute == alarm.minute &&
          isAmNow == alarm.isAm &&
          now.second == 0) {
        // Fire once per minute tick
        alarm.enabled = false;
        _persist();
        _openRinging(alarm);
        break;
      }
    }
  }

  Future<void> _openRinging(Alarm alarm) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => RingingScreen(alarm: alarm),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('h:mm').format(_now);
    final ampm = DateFormat('a').format(_now);
    final dateText = DateFormat('EEEE, MMMM d').format(_now);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.bgTop, AppTheme.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppTheme.accent, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'CURRENT TIME',
                      style: TextStyle(
                        color: AppTheme.accent,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textPrimary,
                      letterSpacing: -2,
                    ),
                    children: [
                      TextSpan(text: timeText),
                      TextSpan(
                        text: ' $ampm',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                          letterSpacing: 0,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(dateText, style: const TextStyle(color: AppTheme.textMuted, fontSize: 18)),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: AppTheme.textMuted, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'ALARMS',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_alarms.length} alarm${_alarms.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppTheme.textMuted),
                    )
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 90),
                    children: [
                      for (final alarm in _alarms)
                        AlarmCard(
                          alarm: alarm,
                          onTap: () {},
                          onLongPress: () => _openRinging(alarm), // quick test
                          onToggle: (v) async {
                            setState(() => alarm.enabled = v);
                            await _persist();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        onPressed: _openNewAlarm,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
