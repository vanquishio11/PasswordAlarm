import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:password_alarm/models/alarm.dart';
import 'package:password_alarm/models/sound.dart';
import 'package:password_alarm/theme/app_theme.dart';

class RingingScreen extends StatefulWidget {
  const RingingScreen({super.key, required this.alarm});

  final Alarm alarm;

  @override
  State<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen> {
  final _passCtrl = TextEditingController();
  Timer? _timer;
  DateTime _now = DateTime.now();
  String? _error;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_passCtrl.text != widget.alarm.password) {
      setState(() => _error = 'Incorrect password');
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm').format(_now);
    final seconds = DateFormat('ss').format(_now);
    final ampm = DateFormat('a').format(_now);
    final sound = AlarmSound.byId(widget.alarm.soundId);

    return Scaffold(
      body: Container(
        color: const Color(0xFF8B6512), // warm mustard
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                const SizedBox(height: 110),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.notifications_none_rounded,
                        size: 46, color: AppTheme.accent.withOpacity(0.9)),
                  ),
                ),
                const SizedBox(height: 26),
                Text(time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 88,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2.5,
                    )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ampm,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' :$seconds',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.35),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  widget.alarm.label.isEmpty ? 'Alarm' : widget.alarm.label,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(sound.name, style: TextStyle(color: Colors.black.withOpacity(0.35), fontSize: 18)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: Colors.black.withOpacity(0.25)),
                    const SizedBox(width: 10),
                    Text('Enter password to dismiss',
                        style: TextStyle(color: Colors.black.withOpacity(0.25), fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (_) => setState(() => _error = null),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFFFE1E1))),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 66,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
                      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      elevation: 0,
                    ),
                    onPressed: _dismiss,
                    child: const Text('Dismiss Alarm'),
                  ),
                ),
                const SizedBox(height: 42),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
