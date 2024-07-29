//import 'package:dima_project/pages/user_info.dart';
import 'package:dima_project/widgets/movies_slider.dart';
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
  late Future<List<Movie>> topRatedMovies;
  late Future<List<Movie>> upcomingMovies;

  @override
  void initState() {
    super.initState();
    trendingMovies = fetchTrendingMovies();
    topRatedMovies = fetchTopRatedMovies();
    upcomingMovies = fetchUpcomingMovies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color.fromARGB(215, 255, 52, 103),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          //Column widget is wrapped with SingleChildScrollView to make the page scrollable
          child: SingleChildScrollView(
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
                //sized box for the trendingMovies widget.
                //It needs to be FutureBuilder, because it first need to retrieve data via api
                const SizedBox(height: 10),
                const Text(
                  'Trending movies',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Top rated movies',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  child: FutureBuilder(
                      future: topRatedMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          return MoviesSlider(
                            snapshot: snapshot,
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Upcoming Movies',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  child: FutureBuilder(
                      future: upcomingMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          return MoviesSlider(
                            snapshot: snapshot,
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      );
}
