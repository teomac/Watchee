// ignore_for_file: deprecated_member_use

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
  int currentPageIndex = 0;

  final List<Widget> screens = [
    const HomeMovies(),
    const MyLists(),
    const FollowView(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brighterColor = Color.alphaBlend(
      colorScheme.surfaceTint.withOpacity(0.04),
      colorScheme.surface,
    );

    // Check if the device is a tablet and in landscape mode
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isTablet && isLandscape) {
      return Scaffold(
        body: Row(
          children: [
            _buildVerticalNavBar(brighterColor),
            Expanded(
              child: screens[currentPageIndex],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        extendBody: true,
        body: Stack(
          children: [
            screens[currentPageIndex],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).padding.bottom,
                color: brighterColor,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(brighterColor),
      );
    }
  }

  Widget _buildVerticalNavBar(Color brighterColor) {
    return Container(
      color: brighterColor,
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              groupAlignment: 0,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              useIndicator: true,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined, size: 24),
                  selectedIcon: Icon(Icons.home, size: 24),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.subscriptions_outlined, size: 24),
                  selectedIcon: Icon(Icons.subscriptions, size: 24),
                  label: Text('My lists'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outlined, size: 24),
                  selectedIcon: Icon(Icons.people, size: 24),
                  label: Text('People'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(Color brighterColor) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: NavigationBar(
        elevation: 3,
        height: 76,
        backgroundColor: brighterColor,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24),
            selectedIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined, size: 24),
            selectedIcon: Icon(Icons.subscriptions, size: 24),
            label: 'My lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined, size: 24),
            selectedIcon: Icon(Icons.people, size: 24),
            label: 'People',
          ),
        ],
      ),
    );
  }
}
