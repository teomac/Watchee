import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/movie.dart';

void main() {
  group('Movie', () {
    test('should create a Movie instance from JSON with all fields', () {
      final json = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'This is a test movie',
        'poster_path': '/test_poster.jpg',
        'backdrop_path': '/test_backdrop.jpg',
        'vote_average': 7.5,
        'release_date': '2024-01-01',
        'genres': [
          {'name': 'Action'},
          {'name': 'Sci-Fi'}
        ],
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 1);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'This is a test movie');
      expect(movie.posterPath, '/test_poster.jpg');
      expect(movie.backdropPath, '/test_backdrop.jpg');
      expect(movie.voteAverage, 7.5);
      expect(movie.releaseDate, '2024-01-01');
      expect(movie.genres, ['Action', 'Sci-Fi']);
    });

    test('should create a Movie instance with missing optional fields', () {
      final json = {
        'id': 2,
        'title': 'Another Test Movie',
        'overview': 'This is another test movie',
        'vote_average': 6.0,
        'genres': [],
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 2);
      expect(movie.title, 'Another Test Movie');
      expect(movie.overview, 'This is another test movie');
      expect(movie.posterPath, null);
      expect(movie.backdropPath, null);
      expect(movie.voteAverage, 6.0);
      expect(movie.releaseDate, 'null'); // Expecting 'null' as a string
      expect(movie.genres, []);
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 3,
        'title': 'Null Test Movie',
        'overview': 'This movie tests null handling',
        'poster_path': null,
        'backdrop_path': null,
        'vote_average': null,
        'release_date': null,
        'genres': null,
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 3);
      expect(movie.title, 'Null Test Movie');
      expect(movie.overview, 'This movie tests null handling');
      expect(movie.posterPath, null);
      expect(movie.backdropPath, null);
      expect(movie.voteAverage, 0.0); // Assuming it defaults to 0.0
      expect(movie.releaseDate, 'null'); // Expecting 'null' as a string
      expect(movie.genres, []); // Assuming it defaults to an empty list
    });

    test('should convert Movie instance to JSON', () {
      final movie = Movie(
        id: 4,
        title: 'Test Movie 4',
        overview: 'This is test movie 4',
        posterPath: '/poster4.jpg',
        backdropPath: '/backdrop4.jpg',
        voteAverage: 8.0,
        releaseDate: '2024-02-01',
        genres: ['Drama', 'Thriller'],
      );

      final json = movie.toJson();

      expect(json['id'], 4);
      expect(json['title'], 'Test Movie 4');
      expect(json['overview'], 'This is test movie 4');
      expect(json['poster_path'], '/poster4.jpg');
      expect(json['backdrop_path'], '/backdrop4.jpg');
      expect(json['vote_average'], 8.0);
      expect(json['release_date'], '2024-02-01');
      expect(json['genres'], ['Drama', 'Thriller']);
    });

    test('should handle null cast and trailer in toJson', () {
      final movie = Movie(
        id: 5,
        title: 'Test Movie 5',
        overview: 'This is test movie 5',
        voteAverage: 7.0,
        genres: [],
      );

      final json = movie.toJson();

      expect(json['cast'], null); // Expecting null (not 'null' as a string)
      expect(json['trailer'], null); // Expecting null (not 'null' as a string)
      expect(json['genres'], []); // Empty genres list
      expect(json['poster_path'], null); // Poster path is null
      expect(json['backdrop_path'], null); // Backdrop path is null
      expect(json['release_date'],
          null); // Expecting null, as per the Movie class definition
    });
  });
}
