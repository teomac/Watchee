import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class FMCService {
  static final Logger logger = Logger();
  static const _storageKey = 'fcm_token';

  static Future<void> storeFCMToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _storageKey, value: token);
  }

  static Future<String?> getFCMToken() async {
    const storage = FlutterSecureStorage();
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
      } catch (e) {
        logger.e("Error saving FCM token to Firestore: $e");
      }
    } else {
      logger.e("User not logged in");
    }
  }

  static void setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await storeFCMToken(newToken);
      await storeFCMTokenToFirestore(newToken);
    });
  }
}
