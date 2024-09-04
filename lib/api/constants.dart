//class used to keep api key and constant useful links to retrieve data from TMDB
class Constants {
  static String apiKey = '7deda61e05cd28b32ad0a2b510923eff';
  static String readAccesToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ZGVkYTYxZTA1Y2QyOGIzMmFkMGEyYjUxMDkyM2VmZiIsInN1YiI6IjY1NDNlMjJmNDFhNTYxMzM2ODgyNTIzOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.caPWqrJ-t62L0AbynTzog1iAusLFsn8Gvsyd_sD2RBE';
  static String imagePath = 'https://image.tmdb.org/t/p/w500';
  static String videoPath = '';
  static String trendingMovie =
      'https://api.themoviedb.org/3/trending/movie/day?api_key=$apiKey';
  static String mostPopular =
      'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
  static String upcoming =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';
  static String topRated =
      'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
  static String movieCredits = '';
  static String similarMovies = '';
  static String movieReviews = '';
  static const String movieBaseUrl = 'https://api.themoviedb.org/3/movie';
}
