import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(1, (int index) {
              const String item = 'test';
              return const ListTile(title: Text(item));
            });
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(destinations: const <Widget>[
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
