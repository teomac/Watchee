import 'package:dima_project/pages/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/login_and_register/login_page.dart';
import 'package:dima_project/pages/login_and_register/welcome_page.dart';
import 'package:provider/provider.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('Auth state changed: ${snapshot.data?.uid}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('Waiting for auth state...');
          return _buildLoadingIndicator();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return StreamBuilder<DocumentSnapshot>(
            // Changed to StreamBuilder
            stream: firestore
                .collection('users')
                .doc(snapshot.data!.uid)
                .snapshots(), // Using snapshots() instead of get()
            builder: (context, userSnapshot) {
              debugPrint(
                  'User document state: ${userSnapshot.connectionState}');
              debugPrint(
                  'User document exists: ${userSnapshot.hasData ? userSnapshot.data?.exists : false}');

              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                debugPrint('No user document found, retrying...');
                return FutureBuilder<DocumentSnapshot>(
                  future: Future.delayed(
                    const Duration(seconds: 1), // Increased delay
                    () => firestore
                        .collection('users')
                        .doc(snapshot.data!.uid)
                        .get(),
                  ),
                  builder: (context, delayedSnapshot) {
                    debugPrint(
                        'Delayed snapshot state: ${delayedSnapshot.connectionState}');
                    if (delayedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingIndicator();
                    }
                    return _buildNavigationDecision(delayedSnapshot);
                  },
                );
              }

              return _buildNavigationDecision(userSnapshot);
            },
          );
        } else {
          debugPrint('No authenticated user found');
          return const LoginPage();
        }
      },
    );
  }

  Widget _buildNavigationDecision(AsyncSnapshot<DocumentSnapshot> snapshot) {
    debugPrint('Building navigation decision...');
    if (snapshot.hasData && snapshot.data!.exists) {
      final userData = snapshot.data!.data() as Map<String, dynamic>?;
      debugPrint('User data: $userData');

      if (userData != null) {
        if (userData['profilePicture'] != null ||
            (userData['name'] != null && userData['name'].isNotEmpty) ||
            (userData['username'] != null && userData['username'].isNotEmpty)) {
          debugPrint('Navigating to Dispatcher');
          return const Dispatcher();
        }
        debugPrint('Navigating to WelcomeScreen');
        return const WelcomeScreen();
      }
    }
    debugPrint('Returning to LoginPage');
    return const LoginPage();
  }

  Widget _buildLoadingIndicator() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
