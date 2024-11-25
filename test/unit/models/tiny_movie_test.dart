import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/tiny_movie.dart';

void main() {
  group('TinyMovie', () {
    test('should create a TinyMovie instance from JSON with all fields', () {
      final json = {
        'id': 1,
        'title': 'Test Movie',
        'poster_path': '/test_poster.jpg',
        'release_date': '2024-01-01',
      };

      final movie = Tinymovie.fromJson(json);

      expect(movie.id, 1);
      expect(movie.title, 'Test Movie');
      expect(movie.posterPath, '/test_poster.jpg');
      expect(movie.releaseDate, '2024-01-01');
    });

    test('should create a TinyMovie instance with missing optional fields', () {
      final json = {
        'id': 2,
        'title': 'Another Test Movie',
      };

      final movie = Tinymovie.fromJson(json);

      expect(movie.id, 2);
      expect(movie.title, 'Another Test Movie');
      expect(movie.posterPath, null);
      expect(movie.releaseDate, 'null');
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 3,
        'title': 'Null Test Movie',
        'poster_path': null,
        'release_date': null,
      };

      final movie = Tinymovie.fromJson(json);

      expect(movie.id, 3);
      expect(movie.title, 'Null Test Movie');
      expect(movie.posterPath, null);
      expect(movie.releaseDate, 'null');
    });

    test('should convert TinyMovie instance to JSON', () {
      final movie = Tinymovie(
        id: 4,
        title: 'Test Movie 4',
        posterPath: '/poster4.jpg',
        releaseDate: '2024-02-01',
      );

      final json = movie.toJson();

      expect(json['id'], 4);
      expect(json['title'], 'Test Movie 4');

      expect(json['poster_path'], '/poster4.jpg');

      expect(json['release_date'], '2024-02-01');
    });

    test('should test equality operator', () {
      final movie1 = Tinymovie(
        id: 1,
        title: 'Movie 1',
      );

      final movie2 = Tinymovie(
        id: 1, // Same ID
        title: 'Different Title', // Different other fields
      );

      final movie3 = Tinymovie(
        id: 2, // Different ID
        title: 'Movie 1',
      );

      expect(movie1 == movie2, true); // Should be equal (same ID)
      expect(movie1 == movie3, false); // Should not be equal (different ID)
      expect(movie1 == movie1, true); // Should be equal (identical)
    });

    test('should test hashCode consistency', () {
      final movie = Tinymovie(
        id: 1,
        title: 'Test Movie',
        posterPath: '/test.jpg',
        releaseDate: '2024-01-01',
      );

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
