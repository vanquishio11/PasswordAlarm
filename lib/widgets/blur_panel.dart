import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:password_alarm/theme/app_theme.dart';

class BlurPanel extends StatelessWidget {
  const BlurPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.panel2.withOpacity(0.75),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.stroke.withOpacity(0.6), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
