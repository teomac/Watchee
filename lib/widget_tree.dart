import 'package:dima_project/pages/dispatcher.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/login_and_register/login_page.dart';
import 'package:dima_project/pages/login_and_register/welcome_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WidgetTree extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final UserService userService;
  WidgetTree(
      {super.key,
      FirebaseAuth? auth,
      FirebaseFirestore? firestore,
      GoogleSignIn? googleSignIn,
      UserService? userService})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn(),
        userService = userService ?? UserService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return FutureBuilder<DocumentSnapshot>(
            future: firestore.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null) {
                  if (userData['profilePicture'] != null ||
                      (userData['name'] != null &&
                          userData['name'].isNotEmpty)) {
                    return const Dispatcher();
                  }
                  return WelcomeScreen(auth: auth, firestore: firestore);
                }
              }
              return LoginPage(
                  auth: auth,
                  firestore: firestore,
                  googleSignIn: googleSignIn,
                  userService: userService);
            },
          );
        } else {
          // User is not signed in
          return LoginPage(
              auth: auth,
              firestore: firestore,
              googleSignIn: googleSignIn,
              userService: userService);
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
