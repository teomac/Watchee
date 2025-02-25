import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/api/key.dart';

void main() {
  group('Constants', () {
    test('apiKey is not empty', () {
      expect(Key.apiKey, isNotEmpty);
    });

    test('imagePath is correct', () {
      expect(Constants.imagePath, equals('https://image.tmdb.org/t/p/w500'));
    });

    test('trendingMovie URL is correctly formed', () {
      expect(
          Constants.trendingMovie,
          equals(
              'https://api.themoviedb.org/3/trending/movie/day?api_key=${Key.apiKey}'));
    });

    test('mostPopular URL is correctly formed', () {
      expect(
          Constants.mostPopular,
          equals(
              'https://api.themoviedb.org/3/movie/popular?api_key=${Key.apiKey}'));
    });

    test('upcoming URL is correctly formed', () {
      expect(
          Constants.upcoming,
          equals(
              'https://api.themoviedb.org/3/movie/upcoming?api_key=${Key.apiKey}'));
    });

    test('topRated URL is correctly formed', () {
      expect(
          Constants.topRated,
          equals(
              'https://api.themoviedb.org/3/movie/top_rated?api_key=${Key.apiKey}'));
    });

    test('nowPlaying URL is correctly formed', () {
      expect(
          Constants.nowPlaying,
          equals(
              'https://api.themoviedb.org/3/movie/now_playing?api_key=${Key.apiKey}'));
    });

    test('movieBaseUrl is correct', () {
      expect(
          Constants.movieBaseUrl, equals('https://api.themoviedb.org/3/movie'));
    });
  });
}
