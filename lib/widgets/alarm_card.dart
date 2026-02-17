import 'package:flutter/material.dart';
import 'package:password_alarm/models/alarm.dart';
import 'package:password_alarm/models/sound.dart';
import 'package:password_alarm/theme/app_theme.dart';

class AlarmCard extends StatelessWidget {
  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress,
  });

  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final sound = AlarmSound.byId(alarm.soundId);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.panel.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.accent.withOpacity(0.35), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        alarm.formatTime(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          alarm.amPm(),
                          style: const TextStyle(
                            fontSize: 26,
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        alarm.label.isEmpty ? 'Alarm' : alarm.label,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                      ),
                      _Chip(label: sound.name, filled: true),
                      _Chip(label: 'Test', icon: Icons.play_arrow_rounded),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: alarm.enabled,
              onChanged: onToggle,
              activeColor: AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, this.filled = false});

  final String label;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? AppTheme.accentSoft : AppTheme.panel2.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.stroke.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.textMuted),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? AppTheme.accent : AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
