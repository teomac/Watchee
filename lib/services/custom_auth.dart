import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:logger/logger.dart';

class CustomAuth {
  final FirebaseAuth _firebaseAuth;
  final Logger logger = Logger();

  CustomAuth({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw 'Please fill in all fields';
    }
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw 'Invalid email or password';
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'wrong-password':
          throw 'Invalid email or password';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        case 'user-disabled':
          throw 'This account has been disabled.';
        default:
          throw 'An error occurred during sign in. Please try again.';
      }
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      logger.e('Error creating user', error: e);
      rethrow;
    }
  }

  Future<bool> signOut() async {
    try {
      logger.d('Starting sign out process');
      await FCMService.clearFCMToken();
      await _firebaseAuth.signOut();
      logger.d('User signed out and FCM token cleared');
      return true;
    } catch (e) {
      logger.e('Failed to sign out: $e');
      return false;
    }
  }
}
