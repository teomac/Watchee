import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:logger/logger.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger logger = Logger();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Exception: ${e.code}', error: e);
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'wrong-password':
          throw 'Wrong password provided for that user.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        case 'user-disabled':
          throw 'This user account has been disabled.';
        case 'ERROR_INVALID_CREDENTIAL':
          throw 'The email or password you entered is invalid.';
        default:
          throw 'An error occurred: ${e.message}';
      }
    } catch (e) {
      logger.e('Unexpected error during sign in', error: e);
      throw 'An unexpected error occurred: $e';
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
