import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:logger/logger.dart';

class CustomGoogleAuth {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserService userService;
  final FirebaseFirestore _firestore;
  final Logger logger = Logger();

  CustomGoogleAuth({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        userService = userService ?? UserService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithCredential(credential);
      } catch (e) {
        logger.e('Firebase Auth Error: $e');
        await _googleSignIn.signOut();
        await _auth.signOut();
        return null;
      }

      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        String username = googleUser.email.split('@')[0];
        //check if the username is unique
        bool isUsernameAvailable =
            await userService.isUsernameAvailable(username);
        int index = 1;
        while (!isUsernameAvailable) {
          username = username + index.toString();
          isUsernameAvailable = await userService.isUsernameAvailable(username);
          index++;
        }

        // Generate a unique username
        try {
          MyUser newUser = MyUser(
            id: userCredential.user!.uid,
            username: username,
            name: googleUser.displayName ?? "",
            email: googleUser.email,
            profilePicture:
                googleUser.photoUrl, // This will be updated in the welcome page
            favoriteGenres: [],
            followers: [],
            following: [],
            likedMovies: [],
            seenMovies: [],
            followedWatchlists: {},
          );

          // Save user data to Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(newUser.toMap());
        } catch (e) {
          logger.e('Error during Google Sign In: $e');
          await _googleSignIn.signOut();
          await _auth.signOut();
          return null;
        }
      }

      try {
        await userService.updateUserWithNameLowerCase(
            userCredential.user!.uid, googleUser.displayName ?? "");
        logger.d('Successfully completed Google Sign In');

        return userCredential;
      } catch (e) {
        logger.e('Error updating user name: $emptyTextSelectionControls');
        return userCredential; // Still return the credential as the main auth succeeded
      }
    } catch (e) {
      logger.e('Error during Google Sign In: $e');
      await _googleSignIn.signOut();
      await _auth.signOut();
      return null;
    }
  }
}
