import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomAuth {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Logger logger = Logger();
  final FCMService _fcmService;

  CustomAuth(
      {FirebaseAuth? firebaseAuth,
      GoogleSignIn? googleSignIn,
      FCMService? fcmService})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _fcmService = fcmService ?? FCMService();

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
      // Clear any existing auth state
      await _firebaseAuth.signOut();

      // Perform new sign in
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify the auth state
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw 'Authentication failed';
      }
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
      await _fcmService.clearFCMToken();
      // Sign out from Google if it was used
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Finally sign out from Firebase
      await _firebaseAuth.signOut();
      logger.d('User signed out and FCM token cleared');
      return true;
    } catch (e) {
      logger.e('Failed to sign out: $e');
      return false;
    }
  }
}
