import 'dart:convert';
import 'dart:math';

import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/movie.dart';
import 'package:http/http.dart' as http;

//function used to retrieve trending movies
Future<List<Movie>> fetchTrendingMovies() async {
  final response = await http.get(Uri.parse(Constants.trendingMovie));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}

//function used to retrieve trending movies
Future<List<Movie>> fetchNowPlayingMovies() async {
  final response = await http.get(Uri.parse(Constants.nowPlaying));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}

//function used to retrieve top rated movies
Future<List<Movie>> fetchTopRatedMovies() async {
  final response = await http.get(Uri.parse(Constants.topRated));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}

//function used to retrieve upcoming movies
Future<List<Movie>> fetchUpcomingMovies() async {
  final response = await http.get(Uri.parse(Constants.upcoming));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}

// function used to retrieve the movie details
Future<Movie> retrieveFilmInfo(int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId?api_key=${Constants.apiKey}'));

  if (response.statusCode == 200) {
    return Movie.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load movie details');
  }
}

// function used to retrieve the cast of a movie
Future<List<Map<String, dynamic>>> retrieveCast(int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId/credits?api_key=${Constants.apiKey}'));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body)['cast'] as List;
    return decodedData
        .map((castMember) => {
              'id': castMember['id'],
              'name': castMember['name'],
              'character': castMember['character'],
              'profile_path': castMember['profile_path']
            })
        .toList();
  } else {
    throw Exception('Failed to load cast information');
  }
}

// function used to retrieve the trailer of a movie
Future<String> retrieveTrailer(int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId/videos?api_key=${Constants.apiKey}'));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body)['results'] as List;
    final trailer = decodedData.firstWhere(
        (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
        orElse: () => null);
    if (trailer != null) {
      final String trailerKey = trailer['key'];
      return trailerKey;
    } else {
      return '';
    }
  } else {
    throw Exception('Failed to load trailer information');
  }
}

// function used to search movies
Future<List<Movie>> searchMovie(String query) async {
  List<Movie> movies = [];
  List<Movie> tempMovies = [];

  for (int i = 1; i < 4; i++) {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=${Constants.apiKey}&query=$query&page=$i'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      tempMovies =
          decodedData.map((movieJson) => Movie.fromJson(movieJson)).toList();
      movies += tempMovies;
    } else {
      throw Exception('Failed to search movies');
    }
  }
  return movies;
}

// Function used to retrieve movies by release date
Future<List<Movie>> fetchMoviesByReleaseDate(String releaseDate) async {
  final response = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&primary_release_date.gte=$releaseDate&primary_release_date.lte=$releaseDate'));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    throw Exception('Failed to load movies releasing on $releaseDate');
  }
}

// function used to retrieve movie providers
Future<Map<String, List<Map<String, dynamic>>>> fetchAllProviders(
    int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId/watch/providers?api_key=${Constants.apiKey}'));

  if (response.statusCode == 200) {
    final decodedData =
        json.decode(response.body)['results'] as Map<String, dynamic>;

    Map<String, List<Map<String, dynamic>>> providersByCountry = {};

    decodedData.forEach((countryCode, data) {
      if (data['flatrate'] != null) {
        final providers = data['flatrate'] as List<dynamic>;
        providersByCountry[countryCode] = providers
            .map((provider) => {
                  'provider_name': provider['provider_name'],
                  'logo_path': provider['logo_path'],
                })
            .toList();
      } else {
        providersByCountry[countryCode] = [];
      }
    });

    return providersByCountry;
  } else {
    throw Exception('Failed to load providers');
  }
}

// function used to retrieve random movies based on genres
Future<List<Movie>> fetchMoviesByGenres(List<int> genreIds) async {
  List<Movie> allMovies = [];

  for (int genreId in genreIds) {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&with_genres=$genreId'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      List<Movie> genreMovies =
          decodedData.map((movie) => Movie.fromJson(movie)).toList();

      //check for duplicates before adding to the list
      for (var movie in genreMovies) {
        if (!allMovies.contains(movie)) {
          allMovies.add(movie);
        }
      }
    } else {
      throw Exception('Failed to load movies for genre $genreId');
    }
  }

  // Shuffle the list of all movies
  allMovies.shuffle(Random());

  // Pick 80 randomly shuffled movies, or all movies if less than 80
  return allMovies.length > 80 ? allMovies.sublist(0, 80) : allMovies;
}
