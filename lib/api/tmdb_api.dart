import 'dart:convert';
import 'dart:math';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:dima_project/models/person.dart';
import 'package:intl/intl.dart';
import 'key.dart';

//function used to retrieve trending movies
Future<List<Movie>> fetchTrendingMovies([http.Client? client]) async {
  client ??= http.Client();
  List<Movie> movies = [];
  List<Movie> trendingMovies = [];

  for (int i = 1; i < 3; i++) {
    final response =
        await http.get(Uri.parse('${Constants.trendingMovie}&page=$i'));

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      final decodedData = json.decode(response.body)['results'] as List;
      movies = decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load trending movies');
    }

    for (var movie in movies) {
      if (!trendingMovies.contains(movie)) {
        trendingMovies.add(movie);
      }
    }
  }

  return trendingMovies;
}

//function used to retrieve trending movies
Future<List<Movie>> fetchNowPlayingMovies() async {
  List<Movie> movies = [];
  List<Movie> nowPlayingMovies = [];

  for (int i = 1; i < 3; i++) {
    final response =
        await http.get(Uri.parse('${Constants.nowPlaying}&page=$i'));
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      final decodedData = json.decode(response.body)['results'] as List;
      movies = decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load now playing movies');
    }

    for (var movie in movies) {
      if (!nowPlayingMovies.contains(movie)) {
        nowPlayingMovies.add(movie);
      }
    }
  }
  return nowPlayingMovies;
}

//function used to retrieve top rated movies
Future<List<Movie>> fetchTopRatedMovies() async {
  List<Movie> movies = [];
  List<Movie> topRatedMovies = [];

  for (int i = 1; i < 3; i++) {
    final response = await http.get(Uri.parse('${Constants.topRated}&page=$i'));
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      final decodedData = json.decode(response.body)['results'] as List;
      movies = decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load top rated movies');
    }

    for (var movie in movies) {
      if (!topRatedMovies.contains(movie)) {
        topRatedMovies.add(movie);
      }
    }
  }

  return topRatedMovies;
}

//function used to retrieve upcoming movies
Future<List<Movie>> fetchUpcomingMovies() async {
  List<Movie> movies = [];
  List<Movie> upcomingMovies = [];

  for (int i = 1; i < 8; i++) {
    final response = await http.get(Uri.parse('${Constants.upcoming}&page=$i'));
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      final decodedData = json.decode(response.body)['results'] as List;
      movies = decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load upcoming movies');
    }

    for (var movie in movies) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      //check for duplicates before adding to the list and check if the release date is in the future
      if (!upcomingMovies.contains(movie) &&
          formatter
              .parse(movie.releaseDate.toString())
              .isAfter(DateTime.now())) {
        upcomingMovies.add(movie);
      }
    }
  }

  return upcomingMovies;
}

// function used to retrieve the movie details
Future<Movie> retrieveFilmInfo(int movieId) async {
  final response = await http.get(
      Uri.parse('${Constants.movieBaseUrl}/$movieId?api_key=${Key.apiKey}'));

  if (response.statusCode == 200) {
    return Movie.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load movie details');
  }
}

// function used to retrieve the cast of a movie
Future<List<Map<String, dynamic>>> retrieveCast(int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId/credits?api_key=${Key.apiKey}'));

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
      '${Constants.movieBaseUrl}/$movieId/videos?api_key=${Key.apiKey}'));

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

  for (int i = 1; i < 3; i++) {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=${Key.apiKey}&query=$query&page=$i'));

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
      'https://api.themoviedb.org/3/discover/movie?api_key=${Key.apiKey}&primary_release_date.gte=$releaseDate&primary_release_date.lte=$releaseDate'));

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
      '${Constants.movieBaseUrl}/$movieId/watch/providers?api_key=${Key.apiKey}'));

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
    for (int i = 1; i < 3; i++) {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?api_key=${Key.apiKey}&with_genres=$genreId&page=$i'));

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
  }

  // Shuffle the list of all movies
  allMovies.shuffle(Random());

  // Pick 80 randomly shuffled movies, or all movies if less than 80
  return allMovies.length > 80 ? allMovies.sublist(0, 80) : allMovies;
}

// function to retrieve the recommended movies based on a specific movie
Future<List<Movie>> fetchRecommendedMovies(int movieId) async {
  final response = await http.get(Uri.parse(
      '${Constants.movieBaseUrl}/$movieId/recommendations?api_key=${Key.apiKey}'));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body)['results'] as List;
    return decodedData.map((movie) => Movie.fromJson(movie)).toList();
  } else {
    throw Exception('Failed to load recommended movies');
  }
}

Future<List<Person>> searchPeople(String query) async {
  List<Person> people = [];
  List<Person> tempPeople = [];

  for (int i = 1; i < 3; i++) {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/person?api_key=${Key.apiKey}&query=$query&page=$i'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      tempPeople = decodedData.map((personJson) {
        // Filter out TV shows from known_for
        var knownForJson = personJson['known_for'] as List<dynamic>;
        var movieKnownFor = knownForJson
            .where((item) => item['media_type'] == 'movie')
            .toList();
        personJson['known_for'] = movieKnownFor;

        return Person.fromJson(personJson);
      }).toList();
      people += tempPeople;
    } else {
      throw Exception('Failed to search people');
    }
  }
  return people;
}

Future<Person> fetchPersonDetails(int personId) async {
  final response = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/person/$personId?api_key=${Key.apiKey}&append_to_response=movie_credits'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Extract all movies from movie_credits
    List<Map<String, dynamic>> allMovies = [];
    if (data['movie_credits'] != null &&
        data['movie_credits']['cast'] != null) {
      allMovies =
          List<Map<String, dynamic>>.from(data['movie_credits']['cast']);

      // Sort movies by release date
      allMovies.sort((a, b) {
        final aDate = a['release_date'] ?? '';
        final bDate = b['release_date'] ?? '';
        return bDate.compareTo(aDate); // Descending order (newest first)
      });
    }

    // Add all movies to the person data
    data['known_for'] = allMovies;

    return Person.fromJson(data);
  } else {
    throw Exception('Failed to load person details');
  }
}

Future<List<Movie>> fetchPersonMovies(int personId) async {
  final response = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/person/$personId/movie_credits?api_key=${Key.apiKey}'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> castMovies = data['cast'];
    return castMovies
        .where((movie) => movie['poster_path'] != null)
        .map((movie) => Movie.fromJson(movie))
        .toList();
  } else {
    throw Exception('Failed to load person movies');
  }
}
