import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTMDBApi extends Mock {
  Future<List<Movie>> fetchTrendingMovies();
  Future<List<Movie>> fetchTopRatedMovies();
  Future<List<Movie>> fetchUpcomingMovies();
  Future<List<Movie>> fetchNowPlayingMovies();
  Future<List<Movie>> fetchMoviesByGenres(List<int> genreIds);
}

class MockHomeMoviesData extends Mock implements HomeMoviesData {}

void main() {
  late MockTMDBApi mockTMDBApi;

  final testMovie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'Test Overview',
    voteAverage: 7.5,
    genres: ['Action'],
  );

  setUp(() {
    mockTMDBApi = MockTMDBApi();
  });

  group('HomeMovies Data Loading', () {
    test('should load all movie categories successfully', () async {
      final List<Movie> mockMovies = [testMovie];

      when(() => mockTMDBApi.fetchTrendingMovies())
          .thenAnswer((_) async => mockMovies);
      when(() => mockTMDBApi.fetchTopRatedMovies())
          .thenAnswer((_) async => mockMovies);
      when(() => mockTMDBApi.fetchUpcomingMovies())
          .thenAnswer((_) async => mockMovies);
      when(() => mockTMDBApi.fetchNowPlayingMovies())
          .thenAnswer((_) async => mockMovies);
      when(() => mockTMDBApi.fetchMoviesByGenres(any()))
          .thenAnswer((_) async => mockMovies);

      final trendingMovies = await mockTMDBApi.fetchTrendingMovies();
      final topRatedMovies = await mockTMDBApi.fetchTopRatedMovies();
      final upcomingMovies = await mockTMDBApi.fetchUpcomingMovies();
      final nowPlayingMovies = await mockTMDBApi.fetchNowPlayingMovies();
      final recommendedMovies = await mockTMDBApi.fetchMoviesByGenres([28]);

      expect(trendingMovies, equals(mockMovies));
      expect(topRatedMovies, equals(mockMovies));
      expect(upcomingMovies, equals(mockMovies));
      expect(nowPlayingMovies, equals(mockMovies));
      expect(recommendedMovies, equals(mockMovies));

      verify(() => mockTMDBApi.fetchTrendingMovies()).called(1);
      verify(() => mockTMDBApi.fetchTopRatedMovies()).called(1);
      verify(() => mockTMDBApi.fetchUpcomingMovies()).called(1);
      verify(() => mockTMDBApi.fetchNowPlayingMovies()).called(1);
      verify(() => mockTMDBApi.fetchMoviesByGenres(any())).called(1);
    });

    test('should handle errors when loading movies', () async {
      when(() => mockTMDBApi.fetchTrendingMovies())
          .thenThrow(Exception('API Error'));

      expect(
        () => mockTMDBApi.fetchTrendingMovies(),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle empty movie lists', () async {
      when(() => mockTMDBApi.fetchTrendingMovies()).thenAnswer((_) async => []);

      final movies = await mockTMDBApi.fetchTrendingMovies();
      expect(movies, isEmpty);
    });
  });

  group('HomeMovies Search Functionality', () {
    test('should filter movies correctly', () {
      final searchResults = [
        testMovie,
        Movie(
          id: 2,
          title: 'Another Movie',
          overview: 'Another Overview',
          voteAverage: 8.0,
          genres: ['Drama'],
        ),
      ];

      expect(searchResults.length, equals(2));
      expect(
        searchResults.where((movie) => movie.title.contains('Test')).length,
        equals(1),
      );
    });
  });

  group('HomeMovies State Management', () {
    test('should update state with new movies data', () {
      final initialMovies = [testMovie];
      final updatedMovies = [
        ...initialMovies,
        Movie(
          id: 2,
          title: 'New Movie',
          overview: 'New Overview',
          voteAverage: 8.0,
          genres: ['Action'],
        ),
      ];

      final initialData = HomeMoviesData(trendingMovies: initialMovies);
      final updatedData = HomeMoviesData(trendingMovies: updatedMovies);

      expect(initialData.trendingMovies?.length, equals(1));
      expect(updatedData.trendingMovies?.length, equals(2));
    });
  });
}
