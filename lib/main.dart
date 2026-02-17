import 'package:flutter/material.dart';
import 'package:password_alarm/screens/home_screen.dart';
import 'package:password_alarm/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PasswordAlarmApp());
}

class PasswordAlarmApp extends StatelessWidget {
  const PasswordAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
