import 'package:dima_project/models/movie.dart';

class HomeMoviesData {
  final List<Movie>? trendingMovies;
  final List<Movie>? topRatedMovies;
  final List<Movie>? upcomingMovies;
  final List<Movie>? nowPlayingMovies;
  final List<Movie>? recommendedMovies;
  HomeMoviesData({
    this.trendingMovies,
    this.topRatedMovies,
    this.upcomingMovies,
    this.nowPlayingMovies,
    this.recommendedMovies,
  });

  HomeMoviesData copyWith(
      {List<Movie>? trendingMovies,
      List<Movie>? topRatedMovies,
      List<Movie>? upcomingMovies,
      List<Movie>? nowPlayingMovies,
      List<Movie>? recommendedMovies}) {
    return HomeMoviesData(
      trendingMovies: trendingMovies ?? this.trendingMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      nowPlayingMovies: nowPlayingMovies ?? this.nowPlayingMovies,
      recommendedMovies: recommendedMovies ?? this.recommendedMovies,
    );
  }
}
