import 'package:dima_project/pages/auth.dart';
import 'package:dima_project/pages/dispatcher.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Dispatcher();
          } else {
            return const LoginPage();
          }
        });
  }
}
