import 'package:dima_project/models/tiny_movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import '../../../mocks/manage_watchlist_page_test.mocks.dart';

// Create a mock class for TMDB API functions
class MockTMDBAPI {
  Future<Movie> retrieveFilmInfo(int movieId) async {
    return Movie(
      id: movieId,
      title: 'Test Movie',
      overview: 'Test Overview',
      voteAverage: 7.5,
      genres: ['Action'],
    );
  }

  Future<String> retrieveTrailer(int movieId) async {
    return 'test-trailer-key';
  }

  Future<List<Map<String, dynamic>>> retrieveCast(int movieId) async {
    return [];
  }
}

@GenerateMocks([WatchlistService])
void main() {
  final testMovie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'Test Overview',
    voteAverage: 7.5,
    genres: ['Action', 'Adventure'],
  );

  final String movie1 = testMovie.toTinyMovie().toString();
  const String movie2 = '2,,, Movie2,,, poster2.jpg,,, 2023-01-02';
  const String movie3 = '3,,, Movie3,,, poster3.jpg,,, 2023-01-03';
  late ManageWatchlistBloc manageWatchlistBloc;
  late MockWatchlistService mockWatchlistService;

  setUp(() {
    mockWatchlistService = MockWatchlistService();
    manageWatchlistBloc = ManageWatchlistBloc(mockWatchlistService);
  });

  tearDown(() {
    manageWatchlistBloc.close();
  });

  group('ManageWatchlistBloc Tests', () {
    final testWatchlist = WatchList(
      id: 'test-watchlist-id',
      userID: 'test-user-id',
      name: 'Test Watchlist',
      isPrivate: false,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      movies: [movie1, movie2, movie3],
      followers: ['follower1'],
      collaborators: ['collab1'],
    );

    test('initial state is ManageWatchlistInitial', () {
      expect(manageWatchlistBloc.state, isA<ManageWatchlistInitial>());
    });

    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'LoadWatchlist emits correct states when successful',
      setUp: () {
        // Clear any previous interactions with the mock
        reset(mockWatchlistService);

        // Setup the mock response for getWatchList
        when(mockWatchlistService.getWatchList(
                'test-user-id', 'test-watchlist-id'))
            .thenAnswer((_) async => testWatchlist);
      },
      build: () => manageWatchlistBloc,
      act: (bloc) => bloc
          .add(LoadWatchlist('test-user-id', 'test-watchlist-id', 'Default')),
      expect: () => [
        isA<ManageWatchlistLoading>(),
        isA<ManageWatchlistLoaded>(),
      ],
      verify: (bloc) {
        verify(mockWatchlistService.getWatchList(
                'test-user-id', 'test-watchlist-id'))
            .called(1);
      },
    );

    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'handles errors gracefully when loading watchlist fails',
      setUp: () {
        when(mockWatchlistService.getWatchList(any, any))
            .thenThrow(Exception('Failed to load watchlist'));
      },
      build: () => manageWatchlistBloc,
      act: (bloc) => bloc
          .add(LoadWatchlist('test-user-id', 'test-watchlist-id', 'Default')),
      expect: () => [
        isA<ManageWatchlistLoading>(),
        isA<ManageWatchlistError>(),
      ],
      verify: (bloc) {
        verify(mockWatchlistService.getWatchList(any, any)).called(1);
        expect(bloc.state, isA<ManageWatchlistError>());
      },
    );
    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'RemoveMovieFromWatchlist emits updated state when successful',
      setUp: () {
        reset(mockWatchlistService);

        Tinymovie mmovie = Tinymovie(
            id: 2,
            title: 'Movie2',
            posterPath: 'poster2.jpg',
            releaseDate: '2023-01-02');

        when(mockWatchlistService.removeMovieFromWatchlist(
                testWatchlist.userID, testWatchlist.id, mmovie))
            .thenAnswer((_) async => {});
      },
      seed: () => ManageWatchlistLoaded(
          testWatchlist, [testMovie.toTinyMovie()], [testMovie.toTinyMovie()]),
      build: () => manageWatchlistBloc,
      act: (bloc) =>
          bloc.add(RemoveMovieFromWatchlist(testMovie.toTinyMovie())),
      expect: () => [
        isA<ManageWatchlistLoaded>(),
      ],
      verify: (bloc) {
        verify(mockWatchlistService.removeMovieFromWatchlist(any, any, any))
            .called(1);
      },
    );

    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'UpdateWatchlistName emits updated state when successful',
      setUp: () {
        reset(mockWatchlistService);

        when(mockWatchlistService.updateWatchList(any))
            .thenAnswer((_) async => {});
      },
      seed: () => ManageWatchlistLoaded(
          testWatchlist, [testMovie.toTinyMovie()], [testMovie.toTinyMovie()]),
      build: () => manageWatchlistBloc,
      act: (bloc) => bloc.add(UpdateWatchlistName('New Name')),
      expect: () => [
        isA<ManageWatchlistLoaded>(),
      ],
      verify: (bloc) {
        verify(mockWatchlistService.updateWatchList(any)).called(1);
      },
    );

    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'ToggleWatchlistPrivacy emits updated state when successful',
      build: () {
        final updatedWatchlist = testWatchlist.copyWith(
          isPrivate: !testWatchlist.isPrivate,
          updatedAt: DateTime.now().toString(),
        );

        when(mockWatchlistService.updateWatchList(updatedWatchlist))
            .thenAnswer((_) async => {});

        return manageWatchlistBloc;
      },
      seed: () => ManageWatchlistLoaded(
          testWatchlist, [testMovie.toTinyMovie()], [testMovie.toTinyMovie()]),
      act: (bloc) => bloc.add(ToggleWatchlistPrivacy()),
      expect: () => [
        isA<ManageWatchlistLoaded>(),
      ],
    );
  });

  group('ManageWatchlist Events Tests', () {
    test('LoadWatchlist event properties', () {
      const userId = 'test-user-id';
      const watchlistId = 'test-watchlist-id';
      const sortOption = 'Default';
      final event = LoadWatchlist(userId, watchlistId, sortOption);

      expect(event.userId, equals(userId));
      expect(event.watchlistId, equals(watchlistId));
      expect(event.sortOption, equals(sortOption));
    });

    test('AddMovieToWatchlist event properties', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 7.5,
        genres: ['Action'],
      );
      final event = AddMovieToWatchlist(movie.toTinyMovie());

      expect(event.movie, equals(movie.toTinyMovie()));
    });

    test('RemoveMovieFromWatchlist event properties', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 7.5,
        genres: ['Action'],
      );
      final event = RemoveMovieFromWatchlist(movie.toTinyMovie());

      expect(event.movie, equals(movie.toTinyMovie()));
    });

    test('UpdateWatchlistName event properties', () {
      const newName = 'New Watchlist Name';
      final event = UpdateWatchlistName(newName);

      expect(event.newName, equals(newName));
    });

    test('ToggleWatchlistPrivacy event creation', () {
      final event = ToggleWatchlistPrivacy();

      expect(event, isA<ManageWatchlistEvent>());
    });
  });

  group('ManageWatchlist States Tests', () {
    test('ManageWatchlistLoading state creation', () {
      final state = ManageWatchlistLoading();
      expect(state, isA<ManageWatchlistState>());
    });

    test('ManageWatchlistLoaded state properties', () {
      final watchlist = WatchList(
        id: 'test-id',
        userID: 'test-user-id',
        name: 'Test List',
        isPrivate: false,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );

      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 7.5,
        genres: ['Action'],
      );

      final movies = [movie.toTinyMovie()];

      final sortedMovies = List<Tinymovie>.from(movies);
      final state = ManageWatchlistLoaded(watchlist, movies, sortedMovies);

      expect(state.watchlist, equals(watchlist));
      expect(state.movies, equals(movies));
      expect(state.sortedMovies, equals(sortedMovies));
    });

    test('ManageWatchlistError state properties', () {
      const errorMessage = 'Test error message';
      final state = ManageWatchlistError(errorMessage);

      expect(state.message, equals(errorMessage));
    });
  });

  group('Sorting Tests', () {
    final movies = [
      Movie(
        id: 1,
        title: 'A Movie',
        overview: 'Overview',
        voteAverage: 7.5,
        genres: ['Action'],
        releaseDate: '2024-01-01',
      ),
      Movie(
        id: 2,
        title: 'B Movie',
        overview: 'Overview',
        voteAverage: 8.0,
        genres: ['Action'],
        releaseDate: '2024-02-01',
      ),
    ];

    test('Default sort maintains original order', () {
      final originalOrder = List.from(movies);
      final sortedMovies = List.from(movies);
      expect(sortedMovies, equals(originalOrder));
    });

    test('Name sort orders movies alphabetically', () {
      final sortedMovies = List.from(movies)
        ..sort((a, b) => a.title.compareTo(b.title));
      expect(sortedMovies.first.title, equals('A Movie'));
      expect(sortedMovies.last.title, equals('B Movie'));
    });

    test('Release Date sort orders movies by date', () {
      final sortedMovies = List.from(movies)
        ..sort((a, b) => b.releaseDate!.compareTo(a.releaseDate!));
      expect(sortedMovies.first.releaseDate, equals('2024-02-01'));
      expect(sortedMovies.last.releaseDate, equals('2024-01-01'));
    });
  });

  group('Error Handling Tests', () {
    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'Emits error state when watchlist not found',
      build: () {
        when(mockWatchlistService.getWatchList(
                'invalid-user', 'invalid-watchlist'))
            .thenAnswer((_) async => null);
        return manageWatchlistBloc;
      },
      act: (bloc) => bloc
          .add(LoadWatchlist('invalid-user', 'invalid-watchlist', 'Default')),
      expect: () => [
        isA<ManageWatchlistLoading>(),
        isA<ManageWatchlistError>(),
      ],
    );

    blocTest<ManageWatchlistBloc, ManageWatchlistState>(
      'Emits error state on service exception',
      build: () {
        when(mockWatchlistService.getWatchList(any, any))
            .thenThrow(Exception('Service error'));
        return manageWatchlistBloc;
      },
      act: (bloc) =>
          bloc.add(LoadWatchlist('user-id', 'watchlist-id', 'Default')),
      expect: () => [
        isA<ManageWatchlistLoading>(),
        isA<ManageWatchlistError>(),
      ],
    );
  });
}
