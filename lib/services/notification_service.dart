import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidInit),
    );
    const channel = AndroidNotificationChannel(
      'flowmind_channel', 'FlowMind Notifications',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showExamReminder({
    required String subject,
    required int daysLeft,
  }) async {
    await _notifications.show(
      subject.hashCode,
      'Exam Reminder',
      daysLeft == 1
          ? '$subject exam is TOMORROW!'
          : 'Only $daysLeft days left for $subject!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowmind_channel', 'FlowMind Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> showStreakReminder(int streak) async {
    await _notifications.show(
      999,
      streak > 0 ? 'Keep your streak alive!' : 'Miss me?',
      streak > 0
          ? 'You have a $streak day streak. Study today!'
          : 'You have not studied today. Start now!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowmind_channel', 'FlowMind Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> showXPMilestone(int level, String title) async {
    await _notifications.show(
      level,
      'Level Up!',
      'You reached Level $level — $title!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowmind_channel', 'FlowMind Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}