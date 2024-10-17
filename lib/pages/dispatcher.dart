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
    return Scaffold(
        backgroundColor: colorScheme.surface,
        extendBody:
            true, // This allows the body to extend behind the navigation bar
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
        bottomNavigationBar: Container(
          padding:
              const EdgeInsets.only(bottom: 4), // Add padding at the bottom
          child: NavigationBar(
            elevation: 3,
            height: 76, // Adjusted height
            backgroundColor: brighterColor,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const <Widget>[
              _CustomNavigationDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              _CustomNavigationDestination(
                icon: Icons.subscriptions_outlined,
                selectedIcon: Icons.subscriptions,
                label: 'My lists',
              ),
              _CustomNavigationDestination(
                icon: Icons.people_outlined,
                selectedIcon: Icons.people,
                label: 'Users',
              ),
            ],
          ),
        ));
  }
}

class _CustomNavigationDestination extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _CustomNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
        icon: Icon(icon, size: 24), // Increase icon size
        selectedIcon: Icon(selectedIcon, size: 24), // Increase icon size
        label: label);
  }
}
