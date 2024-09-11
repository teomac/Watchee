import 'dart:convert';

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
    final String trailerKey = trailer['key'];
    return trailerKey;
  } else {
    throw Exception('Failed to load trailer information');
  }
}

// function used to search movies
Future<List<Movie>> searchMovie(String query) async {
  final response = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/search/movie?api_key=${Constants.apiKey}&query=$query'));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movieJson) => Movie.fromJson(movieJson)).toList();
  } else {
    throw Exception('Failed to search movies');
  }
}
