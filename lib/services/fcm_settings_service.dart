import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMSettingsService {
  final String _pushNotificationsKey = 'push_notifications_enabled';
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isPushNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pushNotificationsKey) ?? true;
    } catch (e) {
      _logger.e('Error checking push notification status: $e');
      return true;
    }
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsKey, enabled);

      if (enabled) {
        final settings = await FirebaseMessaging.instance.requestPermission();
        _logger.i('User granted permission: ${settings.authorizationStatus}');

        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _logger.i('New FCM Token obtained: $token');
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': token,
          });
        }
      } else {
        await FirebaseMessaging.instance.deleteToken();
        _logger.i('FCM Token deleted');

        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
      }
    } catch (e) {
      _logger.e('Error setting push notification status: $e');
      rethrow;
    }
  }
}
