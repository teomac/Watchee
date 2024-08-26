import 'package:dima_project/models/movie.dart';

class HomeMoviesData {
  final List<Movie>? trendingMovies;
  final List<Movie>? topRatedMovies;
  final List<Movie>? upcomingMovies;
  HomeMoviesData({
    this.trendingMovies,
    this.topRatedMovies,
    this.upcomingMovies,
  });

  HomeMoviesData copyWith({
    List<Movie>? trendingMovies,
    List<Movie>? topRatedMovies,
    List<Movie>? upcomingMovies,
  }) {
    return HomeMoviesData(
      trendingMovies: trendingMovies ?? this.trendingMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
    );
  }
}
