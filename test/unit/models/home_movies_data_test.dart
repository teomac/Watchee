import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/models/movie.dart';

void main() {
  group('HomeMoviesData', () {
    test('constructor creates instance with correct properties', () {
      final trendingMovies = [
        Movie(
            id: 1,
            title: 'Trending Movie',
            overview: 'Overview',
            voteAverage: 7.5,
            genres: [])
      ];
      final topRatedMovies = [
        Movie(
            id: 2,
            title: 'Top Rated Movie',
            overview: 'Overview',
            voteAverage: 8.5,
            genres: [])
      ];
      final upcomingMovies = [
        Movie(
            id: 3,
            title: 'Upcoming Movie',
            overview: 'Overview',
            voteAverage: 6.5,
            genres: [])
      ];
      final nowPlayingMovies = [
        Movie(
            id: 4,
            title: 'Now Playing Movie',
            overview: 'Overview',
            voteAverage: 7.0,
            genres: [])
      ];
      final recommendedMovies = [
        Movie(
            id: 5,
            title: 'Recommended Movie',
            overview: 'Overview',
            voteAverage: 8.0,
            genres: [])
      ];

      final homeMoviesData = HomeMoviesData(
        trendingMovies: trendingMovies,
        topRatedMovies: topRatedMovies,
        upcomingMovies: upcomingMovies,
        nowPlayingMovies: nowPlayingMovies,
        recommendedMovies: recommendedMovies,
      );

      expect(homeMoviesData.trendingMovies, equals(trendingMovies));
      expect(homeMoviesData.topRatedMovies, equals(topRatedMovies));
      expect(homeMoviesData.upcomingMovies, equals(upcomingMovies));
      expect(homeMoviesData.nowPlayingMovies, equals(nowPlayingMovies));
      expect(homeMoviesData.recommendedMovies, equals(recommendedMovies));
    });

    test('copyWith updates only specified fields', () {
      final initialData = HomeMoviesData(
        trendingMovies: [
          Movie(
              id: 1,
              title: 'Trending Movie',
              overview: 'Overview',
              voteAverage: 7.5,
              genres: [])
        ],
        topRatedMovies: [
          Movie(
              id: 2,
              title: 'Top Rated Movie',
              overview: 'Overview',
              voteAverage: 8.5,
              genres: [])
        ],
        upcomingMovies: [
          Movie(
              id: 3,
              title: 'Upcoming Movie',
              overview: 'Overview',
              voteAverage: 6.5,
              genres: [])
        ],
        nowPlayingMovies: [
          Movie(
              id: 4,
              title: 'Now Playing Movie',
              overview: 'Overview',
              voteAverage: 7.0,
              genres: [])
        ],
        recommendedMovies: [
          Movie(
              id: 5,
              title: 'Recommended Movie',
              overview: 'Overview',
              voteAverage: 8.0,
              genres: [])
        ],
      );

      final newTrendingMovies = [
        Movie(
            id: 6,
            title: 'New Trending Movie',
            overview: 'New Overview',
            voteAverage: 9.0,
            genres: [])
      ];
      final newRecommendedMovies = [
        Movie(
            id: 7,
            title: 'New Recommended Movie',
            overview: 'New Overview',
            voteAverage: 8.5,
            genres: [])
      ];

      final updatedData = initialData.copyWith(
        trendingMovies: newTrendingMovies,
        recommendedMovies: newRecommendedMovies,
      );

      expect(updatedData.trendingMovies, equals(newTrendingMovies));
      expect(updatedData.topRatedMovies, equals(initialData.topRatedMovies));
      expect(updatedData.upcomingMovies, equals(initialData.upcomingMovies));
      expect(
          updatedData.nowPlayingMovies, equals(initialData.nowPlayingMovies));
      expect(updatedData.recommendedMovies, equals(newRecommendedMovies));
    });
  });
}
