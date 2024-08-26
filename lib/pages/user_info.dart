import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/pages/auth.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/pages/login_page.dart';

class UserInfo extends StatefulWidget {
  UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    try {
      await Auth().signOut();
      // After successful sign out, navigate to the login page
      if (mounted) {
        // Check if the widget is still in the tree
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out. Please try again.')),
      );
    }
  }

  Widget _userId() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _userId(),
        _signOutButton(),
      ],
    );
  }
}
