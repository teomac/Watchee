import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/pages/watchlists/liked_seen_movies_page.dart';

import 'liked_seen_movies_page_test.mocks.dart';

@GenerateMocks([UserService, TmdbApiService])
void main() {
  final testMovie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'Test Overview',
    voteAverage: 7.5,
    genres: ['Action', 'Adventure'],
  );

  final testMovie2 = Movie(
    id: 2,
    title: 'Test Movie 2',
    overview: 'Test Overview 2',
    voteAverage: 8.0,
    genres: ['Action', 'Adventure'],
  );
  late LikedSeenMoviesBloc likedSeenMoviesBloc;
  late MockUserService mockUserService;
  late MockTmdbApiService mockTmdbApiService;

  setUp(() {
    mockUserService = MockUserService();
    mockTmdbApiService = MockTmdbApiService();
    likedSeenMoviesBloc =
        LikedSeenMoviesBloc(mockUserService, mockTmdbApiService);
  });

  tearDown(() {
    likedSeenMoviesBloc.close();
  });

  group('LikeSeenMoviesBloc Tests', () {
    final testUser = MyUser(
      id: 'test-user-id',
      username: 'matlai2300',
      name: 'matteo',
      email: 'test@gmail.com',
      likedMovies: [
        testMovie.toTinyMovie().toString(),
        testMovie2.toTinyMovie().toString()
      ],
      seenMovies: [testMovie.toTinyMovie().toString()],
    );

    final List<Movie> testMovies = [testMovie, testMovie2];

    test('initial state is LikedSeenMoviesInitial', () {
      expect(likedSeenMoviesBloc.state, isA<LikedSeenMoviesInitial>());
    });

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'LoadMovies (likedMovies) emits correct states when successful',
      setUp: () {
        // Clear any previous interactions with the mock
        reset(mockUserService);

        // Setup the mock response for getWatchList
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
        when(mockTmdbApiService.retrieveFilmInfo(testMovie.id))
            .thenAnswer((_) async => testMovie);
        when(mockTmdbApiService.retrieveFilmInfo(testMovie2.id))
            .thenAnswer((_) async => testMovie2);
        when(mockTmdbApiService.retrieveTrailer(testMovie.id))
            .thenAnswer((_) async => 'test-trailer-key');
        when(mockTmdbApiService.retrieveTrailer(testMovie2.id))
            .thenAnswer((_) async => 'test-trailer-key');
      },
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(LoadMovies('test-user-id', true)),
      expect: () => [
        isA<LikedSeenMoviesLoading>(),
        isA<LikedSeenMoviesLoaded>(),
      ],
      verify: (bloc) {
        verify(mockUserService.getUser('test-user-id')).called(1);
        LikedSeenMoviesLoaded(testMovies).movies.contains(testMovie);
        LikedSeenMoviesLoaded(testMovies).movies.contains(testMovie2);
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'LoadMovies (seenMovies) emits correct states when successful',
      setUp: () {
        // Clear any previous interactions with the mock
        reset(mockUserService);

        // Setup the mock response for getWatchList
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
        when(mockTmdbApiService.retrieveFilmInfo(testMovie.id))
            .thenAnswer((_) async => testMovie);
        when(mockTmdbApiService.retrieveFilmInfo(testMovie2.id))
            .thenAnswer((_) async => testMovie2);
        when(mockTmdbApiService.retrieveTrailer(testMovie.id))
            .thenAnswer((_) async => 'test-trailer-key');
        when(mockTmdbApiService.retrieveTrailer(testMovie2.id))
            .thenAnswer((_) async => 'test-trailer-key');
      },
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(LoadMovies('test-user-id', false)),
      expect: () => [
        isA<LikedSeenMoviesLoading>(),
        isA<LikedSeenMoviesLoaded>(),
      ],
      verify: (bloc) {
        verify(mockUserService.getUser('test-user-id')).called(1);

        LikedSeenMoviesLoaded([testMovie]).movies.contains(testMovie);
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'handles errors gracefully when loading movies fails',
      setUp: () {
        when(mockUserService.getUser(any))
            .thenThrow(Exception('Failed to load user'));
      },
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(LoadMovies('test-user-id', true)),
      expect: () => [
        isA<LikedSeenMoviesLoading>(),
        isA<LikedSeenMoviesError>(),
      ],
      verify: (bloc) {
        verify(mockUserService.getUser(any)).called(1);
        expect(bloc.state, isA<LikedSeenMoviesError>());
      },
    );
    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'RemoveMovie (liked) emits updated state when successful',
      setUp: () {
        reset(mockUserService);

        when(mockUserService.removeFromLikedMovies(
                'test-user-id', testMovie.toTinyMovie().toString()))
            .thenAnswer((_) async => {});
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
      },
      seed: () => LikedSeenMoviesLoaded([testMovie, testMovie2]),
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(RemoveMovie(
          'test-user-id', testMovie.toTinyMovie().toString(), true)),
      verify: (bloc) {
        verify(mockUserService.removeFromLikedMovies(any, any)).called(1);
        LikedSeenMoviesLoaded([testMovie2]).movies.contains(testMovie2);
        !LikedSeenMoviesLoaded([testMovie2]).movies.contains(testMovie);
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'RemoveMovie (seen) emits updated state when successful',
      setUp: () {
        reset(mockUserService);

        when(mockUserService.removeFromSeenMovies(
                'test-user-id', testMovie.toTinyMovie().toString()))
            .thenAnswer((_) async => {});
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
      },
      seed: () => LikedSeenMoviesLoaded([testMovie]),
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(RemoveMovie(
          'test-user-id', testMovie.toTinyMovie().toString(), false)),
      verify: (bloc) {
        verify(mockUserService.removeFromSeenMovies(any, any)).called(1);
        (LikedSeenMoviesLoaded([]).movies.isEmpty);
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'handles errors gracefully when removing movie fails',
      setUp: () {
        reset(mockUserService);

        when(mockUserService.removeFromLikedMovies(
                'test-user-id', testMovie.toTinyMovie().toString()))
            .thenThrow(Exception('Failed to remove movie'));
      },
      seed: () => LikedSeenMoviesLoaded([testMovie, testMovie2]),
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(RemoveMovie(
          'test-user-id', testMovie.toTinyMovie().toString(), true)),
      expect: () => [
        isA<LikedSeenMoviesError>(),
      ],
      verify: (bloc) {
        verify(mockUserService.removeFromLikedMovies(any, any)).called(1);
        expect(bloc.state, isA<LikedSeenMoviesError>());
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'handles errors gracefully when removing movie (liked) fails',
      setUp: () {
        reset(mockUserService);

        when(mockUserService.removeFromLikedMovies(
                'test-user-id', testMovie.toTinyMovie().toString()))
            .thenThrow(Exception('Failed to remove movie'));
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
      },
      seed: () => LikedSeenMoviesLoaded([testMovie, testMovie2]),
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(RemoveMovie(
          'test-user-id', testMovie.toTinyMovie().toString(), true)),
      expect: () => [
        isA<LikedSeenMoviesError>(),
      ],
      verify: (bloc) {
        verify(mockUserService.removeFromLikedMovies(any, any)).called(1);
        expect(bloc.state, isA<LikedSeenMoviesError>());
      },
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'handles errors gracefully when removing movie (seen) fails',
      setUp: () {
        reset(mockUserService);

        when(mockUserService.removeFromSeenMovies(
                'test-user-id', testMovie.toTinyMovie().toString()))
            .thenThrow(Exception('Failed to remove movie'));
        when(mockUserService.getUser('test-user-id'))
            .thenAnswer((_) async => testUser);
      },
      seed: () => LikedSeenMoviesLoaded([testMovie]),
      build: () => likedSeenMoviesBloc,
      act: (bloc) => bloc.add(RemoveMovie(
          'test-user-id', testMovie.toTinyMovie().toString(), false)),
      expect: () => [
        isA<LikedSeenMoviesError>(),
      ],
      verify: (bloc) {
        verify(mockUserService.removeFromSeenMovies(any, any)).called(1);
        expect(bloc.state, isA<LikedSeenMoviesError>());
      },
    );

    group('LikedSeenMovies Events Tests', () {
      test('LoadMovies event properties', () {
        const userId = 'test-user-id';

        final event = LoadMovies(userId, true);
        final event2 = LoadMovies(userId, false);

        expect(event.userId, equals(userId));
        expect(event2.userId, equals(userId));
      });

      test('RemoveMovieFromWatchlist event properties', () {
        const userId = 'test-user-id';
        final movie = Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Test Overview',
          voteAverage: 7.5,
          genres: ['Action'],
        );
        final event = RemoveMovie(userId, movie.toTinyMovie().toString(), true);
        final event2 =
            RemoveMovie(userId, movie.toTinyMovie().toString(), false);

        expect(event.userId, equals(userId));
        expect(event.movie, equals(movie.toTinyMovie().toString()));
        expect(event2.userId, equals(userId));
        expect(event2.movie, equals(movie.toTinyMovie().toString()));
      });
    });

    group('LikedSeenMovies States Tests', () {
      test('LikedSeenMoviesLoading state creation', () {
        final state = LikedSeenMoviesLoading();
        expect(state, isA<LikedSeenMoviesState>());
      });

      test('LikedSeenMoviesLoaded state properties', () {
        final movies = [
          Movie(
            id: 1,
            title: 'Test Movie',
            overview: 'Test Overview',
            voteAverage: 7.5,
            genres: ['Action'],
          ),
          Movie(
            id: 2,
            title: 'Test Movie2',
            overview: 'Test Overview2',
            voteAverage: 8.5,
            genres: ['Drama'],
          ),
        ];

        final state = LikedSeenMoviesLoaded(movies);

        expect(state.movies, equals(movies));
      });

      test('LikedSeenMoviesError state properties', () {
        const errorMessage = 'Test error message';
        final state = LikedSeenMoviesError(errorMessage);

        expect(state.message, equals(errorMessage));
      });
    });
  });

  group('Error Handling Tests', () {
    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'Emits error state when user not found',
      build: () {
        when(mockUserService.getUser('invalid-user'))
            .thenAnswer((_) async => null);
        return likedSeenMoviesBloc;
      },
      act: (bloc) => bloc.add(LoadMovies('invalid-user', true)),
      expect: () => [
        isA<LikedSeenMoviesLoading>(),
        isA<LikedSeenMoviesError>(),
      ],
    );

    blocTest<LikedSeenMoviesBloc, LikedSeenMoviesState>(
      'Emits error state on service exception',
      build: () {
        when(mockUserService.getUser(any))
            .thenThrow(Exception('Service error'));
        return likedSeenMoviesBloc;
      },
      act: (bloc) => bloc.add(LoadMovies('user-id', true)),
      expect: () => [
        isA<LikedSeenMoviesLoading>(),
        isA<LikedSeenMoviesError>(),
      ],
    );
  });
}
