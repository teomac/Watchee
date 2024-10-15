import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/genres.dart';

void main() {
  group('MovieGenres', () {
    late MovieGenres movieGenres;

    setUp(() {
      movieGenres = MovieGenres();
    });

    test('getGenre returns correct genre name', () {
      expect(movieGenres.getGenre(28), equals('Action'));
      expect(movieGenres.getGenre(12), equals('Adventure'));
      expect(movieGenres.getGenre(16), equals('Animation'));
    });

    test('getIdFromName returns correct genre id', () {
      expect(movieGenres.getIdFromName('Action'), equals(28));
      expect(movieGenres.getIdFromName('Adventure'), equals(12));
      expect(movieGenres.getIdFromName('Animation'), equals(16));
    });

    test('getIdFromName returns -1 for non-existent genre', () {
      expect(movieGenres.getIdFromName('NonExistentGenre'), equals(-1));
    });

    test('getGenreIdsFromNames returns correct list of ids', () {
      final ids = movieGenres
          .getGenreIdsFromNames(['Action', 'Comedy', 'Drama'], movieGenres);
      expect(ids, equals([28, 35, 18]));
    });

    test('getGenreIdsFromNames ignores non-existent genres', () {
      final ids = movieGenres.getGenreIdsFromNames(
          ['Action', 'NonExistent', 'Drama'], movieGenres);
      expect(ids, equals([28, 18]));
    });
  });

  group('TvShowsGenres', () {
    late TvShowsGenres tvShowsGenres;

    setUp(() {
      tvShowsGenres = TvShowsGenres();
    });

    test('getGenre returns correct genre name', () {
      expect(tvShowsGenres.getGenre(10759), equals('Action & Adventure'));
      expect(tvShowsGenres.getGenre(16), equals('Animation'));
      expect(tvShowsGenres.getGenre(35), equals('Comedy'));
    });
  });
}
