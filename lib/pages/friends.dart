import 'package:dima_project/pages/user_info.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text('Friends page'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: [UserInfo()]),
        ),
      );
}
