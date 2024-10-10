import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class FCMSettingsService {
  static const String _pushNotificationsKey = 'push_notifications_enabled';
  static final Logger _logger = Logger();

  static Future<bool> isPushNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pushNotificationsKey) ?? true;
    } catch (e) {
      _logger.e('Error checking push notification status: $e');
      return true;
    }
  }

  static Future<void> setPushNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsKey, enabled);

      if (enabled) {
        final settings = await FirebaseMessaging.instance.requestPermission();
        _logger.i('User granted permission: ${settings.authorizationStatus}');

        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _logger.i('New FCM Token obtained: $token');
        }

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        _logger.i('Foreground notification options set');
      } else {
        await FirebaseMessaging.instance.deleteToken();
        _logger.i('FCM Token deleted');

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
        _logger.i('Foreground notification options disabled');
      }
    } catch (e) {
      _logger.e('Error setting push notification status: $e');
      rethrow;
    }
  }
}
