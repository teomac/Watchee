import 'package:dima_project/pages/user_info.dart';
import 'package:flutter/material.dart';

class HomeMovies extends StatelessWidget {
  const HomeMovies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              SearchAnchor(
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
              UserInfo(),
            ],
          )));
}
