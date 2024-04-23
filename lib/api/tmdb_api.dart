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

//TODO
//all the function for popular, higher rated, ecc.
