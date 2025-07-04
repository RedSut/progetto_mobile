import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(const InitializationSettings(android: settings));
  }

  Future<void> showNotification(String title, String body) async {
    const details = AndroidNotificationDetails(
      'pet_channel',
      'Pet Status',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notifications.show(0, title, body, const NotificationDetails(android: details));
  }
}