import 'package:dima_project/pages/friends.dart';
import 'package:dima_project/pages/home_movies.dart';
import 'package:dima_project/pages/my_lists.dart';
import 'package:flutter/material.dart';

class Dispatcher extends StatefulWidget {
  Dispatcher({super.key});

  @override
  DispatcherState createState() => DispatcherState();
}

class DispatcherState extends State<Dispatcher> {
  int index = 0;

  final screens = [HomeMovies(), MyLists(), Friends()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.subscriptions),
              label: 'My lists',
            ),
            NavigationDestination(
              icon: Icon(Icons.people),
              label: 'Friends',
            ),
          ]),
    ));
  }
}
