import 'package:dima_project/pages/user_info.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/api/tmdb_api.dart';

class HomeMovies extends StatefulWidget {
  @override
  State<HomeMovies> createState() => HomeMoviesState();
}

class HomeMoviesState extends State<HomeMovies> {
  late Future<List<Movie>> trendingMovies;

  @override
  void initState() {
    super.initState();
    trendingMovies = fetchTrendingMovies();
  }

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
              //sized box for the trendingMovies widget.
              //It needs to be FutureBuilder, because it first need to retrieve data via api
              SizedBox(
                child: FutureBuilder(
                    future: trendingMovies,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else if (snapshot.hasData) {
                        return TrendingSlider(
                          snapshot: snapshot,
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              )
            ],
          ),
        ),
      );
}
