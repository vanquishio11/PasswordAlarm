import 'package:flutter/material.dart';
import 'package:password_alarm/screens/home_screen.dart';
import 'package:password_alarm/theme/app_theme.dart';
import 'services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsService.instance.init();
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
