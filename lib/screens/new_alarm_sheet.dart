import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_alarm/models/alarm.dart';
import 'package:password_alarm/models/sound.dart';
import 'package:password_alarm/theme/app_theme.dart';
import 'package:password_alarm/widgets/blur_panel.dart';

class NewAlarmSheet extends StatefulWidget {
  const NewAlarmSheet({super.key});

  @override
  State<NewAlarmSheet> createState() => _NewAlarmSheetState();
}

class _NewAlarmSheetState extends State<NewAlarmSheet> {
  int _hour = 1;
  int _minute = 0;
  bool _isAm = true;

  final _labelCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  String _soundId = 'radar';
  bool _showSoundList = false;
  String? _error;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _error = _passCtrl.text.trim().isEmpty ? 'Password is required to save the alarm' : null;
    });
  }

  void _save() {
    _validate();
    if (_error != null) return;

    final id = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final alarm = Alarm(
      id: id,
      hour: _hour,
      minute: _minute,
      isAm: _isAm,
      enabled: true,
      label: _labelCtrl.text.trim(),
      soundId: _soundId,
      password: _passCtrl.text,
    );
    Navigator.of(context).pop(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 70, 14, 12),
          child: BlurPanel(
            borderRadius: 28,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    onClose: () => Navigator.of(context).pop(),
                    onSave: _save,
                    saveEnabled: _passCtrl.text.trim().isNotEmpty,
                  ),
                  const SizedBox(height: 22),
                  const Text('SET TIME',
                      style: TextStyle(color: AppTheme.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  _TimePicker(
                    hour: _hour,
                    minute: _minute,
                    isAm: _isAm,
                    onChanged: (h, m, isAm) => setState(() {
                      _hour = h;
                      _minute = m;
                      _isAm = isAm;
                    }),
                  ),
                  const SizedBox(height: 18),
                  const Text('LABEL (OPTIONAL)',
                      style: TextStyle(color: AppTheme.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _labelCtrl,
                    hint: 'e.g., Wake up, Gym, Meeting...',
                    prefixIcon: Icons.local_offer_outlined,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  const Text('ALARM SOUND',
                      style: TextStyle(color: AppTheme.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  _SoundTile(
                    sound: AlarmSound.byId(_soundId),
                    onChange: () => setState(() => _showSoundList = !_showSoundList),
                  ),
                  if (_showSoundList) ...[
                    const SizedBox(height: 12),
                    for (final s in AlarmSound.all)
                      _SoundOption(
                        sound: s,
                        selected: s.id == _soundId,
                        onTap: () => setState(() => _soundId = s.id),
                      ),
                  ],
                  const SizedBox(height: 16),
                  const Text('DISMISS PASSWORD',
                      style: TextStyle(color: AppTheme.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  const Text(
                    'You will need to enter this password to turn off the alarm',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _passCtrl,
                    hint: 'Enter a password...',
                    obscure: !_showPass,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: _showPass ? Icons.visibility_off : Icons.visibility,
                    onSuffixTap: () => setState(() => _showPass = !_showPass),
                    onChanged: (_) {
                      _validate();
                      setState(() {}); // to enable/disable save
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Color(0xFFFF5A5A))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.onSave, required this.saveEnabled});

  final VoidCallback onClose;
  final VoidCallback onSave;
  final bool saveEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.close_rounded, onTap: onClose),
        const Spacer(),
        const Text('New Alarm', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: saveEnabled ? onSave : null,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: saveEnabled ? AppTheme.accent : AppTheme.panel2.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                color: saveEnabled ? Colors.black : AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppTheme.panel2.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textMuted),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.isAm,
    required this.onChanged,
  });

  final int hour;
  final int minute;
  final bool isAm;
  final void Function(int hour, int minute, bool isAm) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.panel2.withOpacity(0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.stroke.withOpacity(0.6)),
      ),
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: hour - 1),
                itemExtent: 44,
                magnification: 1.15,
                onSelectedItemChanged: (i) => onChanged(i + 1, minute, isAm),
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                children: List.generate(
                  12,
                  (i) => Center(
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: i + 1 == hour ? AppTheme.accent : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: minute),
                itemExtent: 44,
                magnification: 1.15,
                onSelectedItemChanged: (i) => onChanged(hour, i, isAm),
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                children: List.generate(
                  60,
                  (i) => Center(
                    child: Text(
                      i.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: i == minute ? AppTheme.accent : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: isAm ? 0 : 1),
                itemExtent: 44,
                magnification: 1.15,
                onSelectedItemChanged: (i) => onChanged(hour, minute, i == 0),
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                children: const [
                  Center(
                    child: Text('AM',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700)),
                  ),
                  Center(
                    child: Text('PM',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700)),
                  ),
                ].map((w) {
                  // We will recolor using DefaultTextStyle below.
                  return w;
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.onChanged,
    this.obscure = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final void Function(String) onChanged;
  final bool obscure;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.panel2.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.stroke.withOpacity(0.55)),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              onChanged: onChanged,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.7)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffixIcon != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffixIcon, color: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({required this.sound, required this.onChange});

  final AlarmSound sound;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.panel2.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.stroke.withOpacity(0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.stroke.withOpacity(0.4)),
            ),
            child: const Icon(Icons.volume_up_rounded, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(sound.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Change', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SoundOption extends StatelessWidget {
  const _SoundOption({required this.sound, required this.selected, required this.onTap});

  final AlarmSound sound;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.panel2.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.accent.withOpacity(0.7) : AppTheme.stroke.withOpacity(0.55),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppTheme.accentSoft : AppTheme.panel.withOpacity(0.45),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.stroke.withOpacity(0.4)),
              ),
              child: Icon(Icons.volume_up_rounded,
                  color: selected ? AppTheme.accent : AppTheme.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sound.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppTheme.accent : AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(sound.desc, style: const TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
