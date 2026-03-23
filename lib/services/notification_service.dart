import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._showLocalNotification(message);
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _fcmToken;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _initLocalNotifications();
      await _getFCMToken();
      _listenToMessages();
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit),
    );
    const channel = AndroidNotificationChannel(
      'flowmind_channel', 'FlowMind Notifications',
      description: 'Study reminders and AI tips',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _getFCMToken() async {
    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken!);
    }
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
    });
  }

  static void _listenToMessages() {
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
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

  static Future<void> showExamReminder({
    required String subject,
    required int daysLeft,
  }) async {
    final msg = daysLeft == 1
        ? '$subject exam is TOMORROW!'
        : 'Only $daysLeft days left for $subject exam!';
    await _localNotifications.show(
      subject.hashCode, 'Exam Reminder', msg,
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
    await _localNotifications.show(
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
    await _localNotifications.show(
      level, 'Level Up!',
      'You reached Level $level — $title! Keep going!',
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

  static String? get fcmToken => _fcmToken;
}
