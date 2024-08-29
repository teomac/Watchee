import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/pages/auth.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final User? user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[],
    );
  }
}
