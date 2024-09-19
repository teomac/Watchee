import 'package:dima_project/pages/follow/follow_page.dart';
import 'package:dima_project/pages/movies/home_movies.dart';
import 'package:dima_project/pages/watchlists/my_lists.dart';
import 'package:flutter/material.dart';

class Dispatcher extends StatefulWidget {
  const Dispatcher({super.key});

  @override
  DispatcherState createState() => DispatcherState();
}

class DispatcherState extends State<Dispatcher> {
  int index = 0;

  final screens = [const HomeMovies(), const MyLists(), const FollowPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            label: 'People',
          ),
        ],
      ),
    );
  }
}
