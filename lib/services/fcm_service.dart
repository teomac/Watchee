import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class FCMService {
  final Logger logger = Logger();
  final _storageKey = 'fcm_token';
  final storage = const FlutterSecureStorage();
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseMessaging messaging;

  FCMService(
      {FirebaseFirestore? firestore,
      FirebaseAuth? auth,
      FirebaseMessaging? messaging})
      : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> storeFCMToken(String token) async {
    await storage.write(key: _storageKey, value: token);
  }

  Future<String?> getFCMToken() async {
    return await storage.read(key: _storageKey);
  }

  Future<void> storeFCMTokenToFirestore(String token) async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        await firestore
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

  void setupTokenRefreshListener() {
    messaging.onTokenRefresh.listen((newToken) async {
      await storeFCMToken(newToken);
      await storeFCMTokenToFirestore(newToken);
    });
  }

  Future<void> clearFCMToken() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        // Remove token from Firestore
        await firestore
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': FieldValue.delete()});

        // Delete the FCM token
        await messaging.deleteToken();

        // Clear from local storage
        await storage.delete(key: _storageKey);

        logger.i("FCM token cleared successfully");
      }
    } catch (e) {
      logger.e("Error clearing FCM token: $e");
      // Don't throw - we want the logout process to continue
    }
  }
}
