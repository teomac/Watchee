//class used to keep api key and constant useful links to retrieve data from TMDB
import 'key.dart';

class Constants {
  static String imagePath = 'https://image.tmdb.org/t/p/w500';
  static String lowQualityImagePath = 'https://image.tmdb.org/t/p/w200';
  static String imageOriginalPath = 'https://image.tmdb.org/t/p/original';
  static String videoPath = '';
  static String trendingMovie =
      'https://api.themoviedb.org/3/trending/movie/day?api_key=${Key.apiKey}';
  static String mostPopular =
      'https://api.themoviedb.org/3/movie/popular?api_key=${Key.apiKey}';
  static String upcoming =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=${Key.apiKey}';
  static String topRated =
      'https://api.themoviedb.org/3/movie/top_rated?api_key=${Key.apiKey}';
  static String nowPlaying =
      'https://api.themoviedb.org/3/movie/now_playing?api_key=${Key.apiKey}';
  static String movieCredits = '';
  static String similarMovies = '';
  static String movieReviews = '';
  static const String movieBaseUrl = 'https://api.themoviedb.org/3/movie';
}
