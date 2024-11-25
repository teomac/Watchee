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
        'runtime': 120,
        'tagline': 'Test tagline',
        'cast': [
          {'name': 'Actor 1', 'character': 'Character 1'},
          {'name': 'Actor 2', 'character': 'Character 2'}
        ],
        'trailer': 'test_trailer_url'
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
      expect(movie.runtime, 120);
      expect(movie.tagline, 'Test tagline');
      expect(movie.cast?.length, 2);
      expect(movie.cast?[0]['name'], 'Actor 1');
      expect(movie.trailer, 'test_trailer_url');
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
      expect(movie.releaseDate, 'null');
      expect(movie.genres, []);
      expect(movie.runtime, null);
      expect(movie.tagline, null);
      expect(movie.cast, null);
      expect(movie.trailer, null);
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
        'runtime': null,
        'tagline': null,
        'cast': null,
        'trailer': null
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 3);
      expect(movie.title, 'Null Test Movie');
      expect(movie.overview, 'This movie tests null handling');
      expect(movie.posterPath, null);
      expect(movie.backdropPath, null);
      expect(movie.voteAverage, 0.0);
      expect(movie.releaseDate, 'null');
      expect(movie.genres, []);
      expect(movie.runtime, null);
      expect(movie.tagline, null);
      expect(movie.cast, null);
      expect(movie.trailer, null);
    });

    test('should convert Movie instance to JSON', () {
      final List<Map<String, dynamic>> testCast = [
        {'name': 'Actor 1', 'character': 'Character 1'},
        {'name': 'Actor 2', 'character': 'Character 2'}
      ];

      final movie = Movie(
          id: 4,
          title: 'Test Movie 4',
          overview: 'This is test movie 4',
          posterPath: '/poster4.jpg',
          backdropPath: '/backdrop4.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-02-01',
          genres: ['Drama', 'Thriller'],
          runtime: 150,
          tagline: 'Epic tagline',
          cast: testCast,
          trailer: 'trailer_url');

      final json = movie.toJson();

      expect(json['id'], 4);
      expect(json['title'], 'Test Movie 4');
      expect(json['overview'], 'This is test movie 4');
      expect(json['poster_path'], '/poster4.jpg');
      expect(json['backdrop_path'], '/backdrop4.jpg');
      expect(json['vote_average'], 8.0);
      expect(json['release_date'], '2024-02-01');
      expect(json['genres'], ['Drama', 'Thriller']);
      expect(json['runtime'], 150);
      expect(json['tagline'], 'Epic tagline');
      expect(json['cast'], testCast);
      expect(json['trailer'], 'trailer_url');
    });

    test('should test equality operator', () {
      final movie1 = Movie(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          voteAverage: 7.5,
          genres: ['Action']);

      final movie2 = Movie(
          id: 1, // Same ID
          title: 'Different Title', // Different other fields
          overview: 'Different Overview',
          voteAverage: 8.0,
          genres: ['Drama']);

      final movie3 = Movie(
          id: 2, // Different ID
          title: 'Movie 1',
          overview: 'Overview 1',
          voteAverage: 7.5,
          genres: ['Action']);

      expect(movie1 == movie2, true); // Should be equal (same ID)
      expect(movie1 == movie3, false); // Should not be equal (different ID)
      expect(movie1 == movie1, true); // Should be equal (identical)
    });

    test('to TinyMovie', () {
      final movie = Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Test Overview',
          posterPath: '/test.jpg',
          releaseDate: '2024-01-01',
          genres: ['Action'],
          cast: [
            {'name': 'Actor'}
          ],
          trailer: 'trailer_url',
          runtime: 120,
          tagline: 'Test Tagline',
          voteAverage: 7.5);

      final tinyMovie = movie.toTinyMovie();

      expect(tinyMovie.id, 1);
      expect(tinyMovie.title, 'Test Movie');
      expect(tinyMovie.posterPath, '/test.jpg');
      expect(tinyMovie.releaseDate, '2024-01-01');
    });

    test('should test hashCode consistency', () {
      final movie = Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Test Overview',
          posterPath: '/test.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-01',
          genres: ['Action'],
          cast: [
            {'name': 'Actor'}
          ],
          trailer: 'trailer_url',
          runtime: 120,
          tagline: 'Test Tagline');

      // Test that hashCode is consistent for the same object
      expect(movie.hashCode, equals(movie.hashCode));

      // Test that hashCode is an integer
      expect(movie.hashCode, isA<int>());

      // Test that identical objects have the same hashCode
      expect(identical(movie, movie), true);
      expect(movie.hashCode, equals(movie.hashCode));
    });
  });
}
