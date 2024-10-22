import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/managers/genre_selection_manager.dart';

void main() {
  group('GenreSelectionManager', () {
    late GenreSelectionManager manager;

    setUp(() {
      manager = GenreSelectionManager();
    });

    test('initial selected genres list is empty', () {
      expect(manager.selectedGenres, isEmpty);
    });

    test('toggleGenre adds genre when not present', () {
      manager.toggleGenre('Action');
      expect(manager.selectedGenres, contains('Action'));
      expect(manager.selectedGenres.length, equals(1));
    });

    test('toggleGenre removes genre when already present', () {
      // Add genre first
      manager.toggleGenre('Action');
      expect(manager.selectedGenres, contains('Action'));

      // Remove genre
      manager.toggleGenre('Action');
      expect(manager.selectedGenres, isEmpty);
    });

    test('hasMinimumGenres returns false when less than 3 genres selected', () {
      manager.toggleGenre('Action');
      manager.toggleGenre('Comedy');
      expect(manager.hasMinimumGenres(), isFalse);
    });

    test('hasMinimumGenres returns true when 3 or more genres selected', () {
      manager.toggleGenre('Action');
      manager.toggleGenre('Comedy');
      manager.toggleGenre('Drama');
      expect(manager.hasMinimumGenres(), isTrue);
    });

    test('selecting same genre twice results in genre being removed', () {
      manager.toggleGenre('Action');
      manager.toggleGenre('Action');
      expect(manager.selectedGenres, isEmpty);
    });

    test('can select multiple different genres', () {
      manager.toggleGenre('Action');
      manager.toggleGenre('Comedy');
      manager.toggleGenre('Drama');
      manager.toggleGenre('Horror');

      expect(manager.selectedGenres.length, equals(4));
      expect(manager.selectedGenres,
          containsAll(['Action', 'Comedy', 'Drama', 'Horror']));
    });

    test('removing genre from middle of selection maintains other selections',
        () {
      // Add multiple genres
      manager.toggleGenre('Action');
      manager.toggleGenre('Comedy');
      manager.toggleGenre('Drama');

      // Remove middle genre
      manager.toggleGenre('Comedy');

      expect(manager.selectedGenres.length, equals(2));
      expect(manager.selectedGenres, containsAll(['Action', 'Drama']));
    });

    test('clearSelection removes all selected genres', () {
      manager.toggleGenre('Action');
      manager.toggleGenre('Comedy');
      manager.clearSelection();
      expect(manager.selectedGenres, isEmpty);
    });

    test('isGenreSelected returns correct status', () {
      manager.toggleGenre('Action');
      expect(manager.isGenreSelected('Action'), isTrue);
      expect(manager.isGenreSelected('Comedy'), isFalse);
    });
  });
}
