import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/pages/auth.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  UserInfo({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
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
