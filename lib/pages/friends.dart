import 'package:dima_project/pages/user_info.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  const Friends({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: const Text('Friends page'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: const Column(children: [UserInfo()]),
        ),
      );
}
