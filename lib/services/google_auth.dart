import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart'; // Import UserService
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger logger = Logger();
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Generate a unique username

        MyUser newUser = MyUser(
          id: userCredential.user!.uid,
          username: googleUser.email.split('@')[0],
          name: googleUser.displayName ?? "",
          email: googleUser.email,
          profilePicture:
              googleUser.photoUrl, // This will be updated in the welcome page
          favoriteGenres: [],
          followers: [],
          following: [],
          likedMovies: [],
          seenMovies: [],
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
      }

      await UserService().updateUserWithNameLowerCase(
          userCredential.user!.uid, googleUser.displayName ?? "");

      return userCredential;
    } catch (e) {
      logger.d("Error during Google sign in: $e");
      return null;
    }
  }
}
