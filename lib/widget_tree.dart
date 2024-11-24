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
                          userData['name'].isNotEmpty) ||
                      (userData['username'] != null &&
                          userData['username'].isNotEmpty)) {
                    return const Dispatcher();
                  }
                  return const WelcomeScreen();
                }
              }
              return const LoginPage();
            },
          );
        } else {
          // User is not signed in
          return const LoginPage();
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
