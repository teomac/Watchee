import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class FCMService {
  static final Logger logger = Logger();
  static const _storageKey = 'fcm_token';
  static const storage = FlutterSecureStorage();

  static Future<void> storeFCMToken(String token) async {
    await storage.write(key: _storageKey, value: token);
  }

  static Future<String?> getFCMToken() async {
    return await storage.read(key: _storageKey);
  }

  static Future<void> storeFCMTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
        logger.i("FCM token stored in Firestore for user: ${user.uid}");
      } catch (e) {
        logger.e("Error saving FCM token to Firestore: $e");
      }
    } else {
      logger.w("Attempted to store FCM token, but no user is logged in");
    }
  }

  static void setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await storeFCMToken(newToken);
      await storeFCMTokenToFirestore(newToken);
    });
  }

  static Future<void> clearFCMToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': FieldValue.delete()});
        logger.i("FCM token removed from Firestore for user: ${user.uid}");
      } catch (e) {
        logger.e("Error removing FCM token from Firestore: $e");
      }
    }
    await storage.delete(key: _storageKey);
    logger.i("FCM token cleared from local storage");
  }
}
