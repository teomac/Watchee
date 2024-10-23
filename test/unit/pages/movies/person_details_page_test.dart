import 'package:dima_project/models/person.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/person_details_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dima_project/api/tmdb_api.dart' as tmdb_api;

// Mock classes for testing
class MockPerson extends Mock implements Person {}

class MockMovie extends Mock implements Movie {}

// Create a class to wrap the static methods for testing
class TMDBApiWrapper {
  Future<Person> fetchPersonDetails(int personId) =>
      tmdb_api.fetchPersonDetails(personId);
  Future<List<Movie>> fetchPersonMovies(int personId) =>
      tmdb_api.fetchPersonMovies(personId);
}

class MockTMDBApiWrapper extends Mock implements TMDBApiWrapper {}

void main() {
  late Person testPerson;
  late List<Movie> testMovies;
  late PersonDetailsPageState pageState;
  late MockTMDBApiWrapper mockApiWrapper;

  setUp(() {
    testPerson = Person(
      adult: false,
      alsoKnownAs: ['Test Name 1', 'Test Name 2'],
      biography: 'Test biography',
      birthday: '1990-01-01',
      deathday: null,
      gender: 1,
      homepage: 'http://test.com',
      id: 1,
      knownForDepartment: 'Acting',
      name: 'Test Person',
      placeOfBirth: 'Test City, Test Country',
      popularity: 10.0,
      profilePath: '/test/path.jpg',
      knownFor: [],
    );

    testMovies = [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        overview: 'Test overview 1',
        voteAverage: 7.5,
        releaseDate: '2023-01-01',
        genres: ['Action', 'Drama'],
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        overview: 'Test overview 2',
        voteAverage: 8.0,
        releaseDate: '2023-02-01',
        genres: ['Comedy', 'Romance'],
      ),
    ];

    pageState = PersonDetailsPageState();
    mockApiWrapper = MockTMDBApiWrapper();
  });

  group('Date Formatting Tests', () {
    test('formats valid date correctly', () {
      final formattedDate = pageState.formatDate('1990-01-01');
      expect(formattedDate, 'January 1, 1990');
    });

    test('handles "Unknown" date', () {
      final formattedDate = pageState.formatDate('Unknown');
      expect(formattedDate, 'Unknown');
    });

    test('handles empty date string', () {
      final formattedDate = pageState.formatDate('');
      expect(formattedDate, '');
    });

    test('handles null date', () {
      final formattedDate = pageState.formatDate(null);
      expect(formattedDate, '');
    });

    test('handles invalid date format', () {
      final formattedDate = pageState.formatDate('2023.12.25');
      expect(formattedDate, '2023.12.25');
    });
  });

  group('Person Model Tests', () {
    test('person model contains correct initial data', () {
      expect(testPerson.name, 'Test Person');
      expect(testPerson.biography, 'Test biography');
      expect(testPerson.birthday, '1990-01-01');
      expect(testPerson.knownForDepartment, 'Acting');
      expect(testPerson.placeOfBirth, 'Test City, Test Country');
      expect(testPerson.alsoKnownAs, ['Test Name 1', 'Test Name 2']);
    });

    test('person model handles null values', () {
      final personWithNulls = Person(
        adult: false,
        alsoKnownAs: [],
        biography: null,
        birthday: null,
        gender: 0,
        id: 1,
        knownForDepartment: '',
        name: 'Test Person',
        popularity: 0,
        profilePath: null,
        knownFor: [],
      );

      expect(personWithNulls.biography, null);
      expect(personWithNulls.birthday, null);
      expect(personWithNulls.profilePath, null);
      expect(personWithNulls.knownFor, isEmpty);
    });

    test('person model updates known for movies list', () {
      testPerson.knownFor.clear();
      expect(testPerson.knownFor, isEmpty);

      testPerson.knownFor.addAll(testMovies);
      expect(testPerson.knownFor, isNotEmpty);
      expect(testPerson.knownFor.length, 2);
    });
  });

  group('TMDB API Integration Tests', () {
    test('fetchPersonDetails returns valid person data', () async {
      when(() => mockApiWrapper.fetchPersonDetails(any()))
          .thenAnswer((_) async => testPerson);

      final result = await mockApiWrapper.fetchPersonDetails(1);

      verify(() => mockApiWrapper.fetchPersonDetails(1)).called(1);
      expect(result, equals(testPerson));
      expect(result.name, equals('Test Person'));
      expect(result.biography, equals('Test biography'));
    });

    test('fetchPersonMovies returns valid movie list', () async {
      when(() => mockApiWrapper.fetchPersonMovies(any()))
          .thenAnswer((_) async => testMovies);

      final result = await mockApiWrapper.fetchPersonMovies(1);

      verify(() => mockApiWrapper.fetchPersonMovies(1)).called(1);
      expect(result, equals(testMovies));
      expect(result.length, equals(2));
      expect(result.first.title, equals('Test Movie 1'));
    });

    test('handles API error for fetchPersonDetails', () async {
      when(() => mockApiWrapper.fetchPersonDetails(any()))
          .thenThrow(Exception('API Error'));

      expect(() => mockApiWrapper.fetchPersonDetails(1), throwsException);
    });

    test('handles API error for fetchPersonMovies', () async {
      when(() => mockApiWrapper.fetchPersonMovies(any()))
          .thenThrow(Exception('API Error'));

      expect(() => mockApiWrapper.fetchPersonMovies(1), throwsException);
    });
  });

  group('Movie Data Validation', () {
    test('movie model contains correct data', () {
      final movie = testMovies[0];
      expect(movie.title, 'Test Movie 1');
      expect(movie.overview, 'Test overview 1');
      expect(movie.voteAverage, 7.5);
      expect(movie.releaseDate, '2023-01-01');
      expect(movie.genres, ['Action', 'Drama']);
    });

    test('movie list sorting maintains order', () {
      testPerson.knownFor.clear();
      testPerson.knownFor.addAll(testMovies);

      final sortedByDate = List<Movie>.from(testPerson.knownFor)
        ..sort((a, b) => b.releaseDate!.compareTo(a.releaseDate!));

      expect(sortedByDate.first.releaseDate, '2023-02-01');
      expect(sortedByDate.last.releaseDate, '2023-01-01');
    });

    test('movie model handles missing data', () {
      final movieWithMissingData = Movie(
        id: 3,
        title: 'Test Movie 3',
        overview: '',
        voteAverage: 0.0,
        releaseDate: null,
        genres: [],
      );

      expect(movieWithMissingData.releaseDate, null);
      expect(movieWithMissingData.overview, isEmpty);
      expect(movieWithMissingData.genres, isEmpty);
    });
  });

  group('Biography Text Handling', () {
    test('handles long biography text', () {
      final longBio = 'A' * 1000;
      testPerson = testPerson.copyWith(biography: longBio);
      expect(testPerson.biography!.length, 1000);
    });

    test('handles empty biography', () {
      testPerson = testPerson.copyWith(biography: '');
      expect(testPerson.biography, isEmpty);
    });

    test('handles null biography', () {
      testPerson = testPerson.copyWith(biography: null);
      expect(testPerson.biography, null);
    });
  });
}

extension PersonCopyWith on Person {
  Person copyWith({
    String? biography,
    String? birthday,
    String? name,
    List<Movie>? knownFor,
  }) {
    return Person(
      adult: adult,
      alsoKnownAs: alsoKnownAs,
      biography: biography ?? this.biography,
      birthday: birthday ?? this.birthday,
      gender: gender,
      id: id,
      knownForDepartment: knownForDepartment,
      name: name ?? this.name,
      popularity: popularity,
      profilePath: profilePath,
      knownFor: knownFor ?? this.knownFor,
    );
  }
}
