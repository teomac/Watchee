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

  HomeMoviesData copyWith({
    Object? trendingMovies = _keepOldValue,
    Object? topRatedMovies = _keepOldValue,
    Object? upcomingMovies = _keepOldValue,
    Object? nowPlayingMovies = _keepOldValue,
    Object? recommendedMovies = _keepOldValue,
  }) {
    return HomeMoviesData(
      trendingMovies: trendingMovies == _keepOldValue
          ? this.trendingMovies
          : trendingMovies as List<Movie>?,
      topRatedMovies: topRatedMovies == _keepOldValue
          ? this.topRatedMovies
          : topRatedMovies as List<Movie>?,
      upcomingMovies: upcomingMovies == _keepOldValue
          ? this.upcomingMovies
          : upcomingMovies as List<Movie>?,
      nowPlayingMovies: nowPlayingMovies == _keepOldValue
          ? this.nowPlayingMovies
          : nowPlayingMovies as List<Movie>?,
      recommendedMovies: recommendedMovies == _keepOldValue
          ? this.recommendedMovies
          : recommendedMovies as List<Movie>?,
    );
  }

  static const _keepOldValue = Object();
}
