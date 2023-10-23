import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:dima_project/widget_tree.dart';
import 'package:dima_project/pages/home_movies.dart';
import 'package:dima_project/pages/my_lists.dart';
import 'package:dima_project/pages/friends.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  final screens = [HomeMovies(), MyLists(), Friends()];

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WidgetTree(),
    );
  }
}
