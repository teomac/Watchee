import 'package:dima_project/models/movie.dart';

class HomeMoviesData {
  final List<Movie>? trendingMovies;
  final List<Movie>? topRatedMovies;
  final List<Movie>? upcomingMovies;
  final List<Movie>? nowPlayingMovies;
  final List<Movie>? recommendedMovies;
  final List<Movie>? dramaMovies;
  final List<Movie>? familyMovies;
  final List<Movie>? documentaryMovies;
  final List<Movie>? animationMovies;
  final List<Movie>? comedyMovies;
  final List<Movie>? horrorMovies;
  HomeMoviesData({
    this.trendingMovies,
    this.topRatedMovies,
    this.upcomingMovies,
    this.nowPlayingMovies,
    this.recommendedMovies,
    this.dramaMovies,
    this.familyMovies,
    this.documentaryMovies,
    this.animationMovies,
    this.comedyMovies,
    this.horrorMovies,
  });

  HomeMoviesData copyWith({
    Object? trendingMovies = _keepOldValue,
    Object? topRatedMovies = _keepOldValue,
    Object? upcomingMovies = _keepOldValue,
    Object? nowPlayingMovies = _keepOldValue,
    Object? recommendedMovies = _keepOldValue,
    Object? dramaMovies = _keepOldValue,
    Object? familyMovies = _keepOldValue,
    Object? documentaryMovies = _keepOldValue,
    Object? animationMovies = _keepOldValue,
    Object? comedyMovies = _keepOldValue,
    Object? horrorMovies = _keepOldValue,
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
      dramaMovies: dramaMovies == _keepOldValue
          ? this.dramaMovies
          : dramaMovies as List<Movie>?,
      familyMovies: familyMovies == _keepOldValue
          ? this.familyMovies
          : familyMovies as List<Movie>?,
      documentaryMovies: documentaryMovies == _keepOldValue
          ? this.documentaryMovies
          : documentaryMovies as List<Movie>?,
      animationMovies: animationMovies == _keepOldValue
          ? this.animationMovies
          : animationMovies as List<Movie>?,
      comedyMovies: comedyMovies == _keepOldValue
          ? this.comedyMovies
          : comedyMovies as List<Movie>?,
      horrorMovies: horrorMovies == _keepOldValue
          ? this.horrorMovies
          : horrorMovies as List<Movie>?,
    );
  }

  static const _keepOldValue = Object();
}
