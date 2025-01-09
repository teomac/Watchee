// ignore_for_file: deprecated_member_use

import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/movies/home_movies.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/models/person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../mocks/w_home_movies_test.mocks.dart';

@GenerateMocks([
  TmdbApiService,
  UserService,
  FirebaseAuth,
  CustomAuth,
  NotificationsService,
])
void main() {
  late MockTmdbApiService mockTmdbApiService;
  late MockUserService mockUserService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockCustomAuth mockCustomAuth;
  late MockNotificationsService mockNotificationsService;
  late MyUser testUser;
  late List<Movie> testMovies;
  late List<Person> testPeople;

  setUp(() {
    mockTmdbApiService = MockTmdbApiService();
    mockUserService = MockUserService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockCustomAuth = MockCustomAuth();
    mockNotificationsService = MockNotificationsService();

    testUser = MyUser(
      id: 'test_user_id',
      email: 'test@test.com',
      username: 'testuser',
      name: 'Test User',
      profilePicture: null,
      favoriteGenres: ['Action', 'Drama'],
      followers: [],
      following: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    testMovies = [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        overview: 'Overview 1',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
        genres: ['Action'],
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        overview: 'Overview 2',
        voteAverage: 7.5,
        releaseDate: '2024-01-02',
        genres: ['Drama'],
      ),
    ];

    testPeople = [
      Person(
        id: 1,
        name: 'Test Actor',
        profilePath: null,
        knownFor: [],
        adult: false,
        gender: 1,
        knownForDepartment: 'Acting',
        popularity: 10,
        alsoKnownAs: [],
      ),
    ];

    // Setup common mock responses
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);

    // Mock all movie fetch methods
    when(mockTmdbApiService.fetchTrendingMovies())
        .thenAnswer((_) async => testMovies);
    when(mockTmdbApiService.fetchTopRatedMovies())
        .thenAnswer((_) async => testMovies);
    when(mockTmdbApiService.fetchUpcomingMovies())
        .thenAnswer((_) async => testMovies);
    when(mockTmdbApiService.fetchNowPlayingMovies())
        .thenAnswer((_) async => testMovies);
    when(mockTmdbApiService.fetchMoviesByGenres(any))
        .thenAnswer((_) async => testMovies);

    // Mock search methods
    when(mockTmdbApiService.searchMovie(any))
        .thenAnswer((_) async => testMovies);
    when(mockTmdbApiService.searchPeople(any))
        .thenAnswer((_) async => testPeople);
    when(mockNotificationsService.unreadCount).thenReturn(0);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<TmdbApiService>.value(value: mockTmdbApiService),
          Provider<UserService>.value(value: mockUserService),
          Provider<FirebaseAuth>.value(value: mockFirebaseAuth),
          Provider<CustomAuth>.value(value: mockCustomAuth),
          Provider<NotificationsService>.value(value: mockNotificationsService),
        ],
        child: const HomeMovies(),
      ),
    );
  }

  group('HomeMovies Widget Tests', () {
    testWidgets('renders initial state correctly', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Verify basic UI elements are present
      expect(find.text('Trending Movies'), findsOneWidget);
      expect(find.text('Recommended for You'), findsOneWidget);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(InkWell), findsOneWidget); // User profile icon
    });

    testWidgets('displays movie sections correctly', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Verify all movie sections are present
      expect(find.text('Trending Movies'), findsWidgets);
      expect(find.text('Recommended for You'), findsWidgets);
      expect(find.text('Top rated Movies'), findsWidgets);
      expect(find.text('Upcoming Movies'), findsWidgets);
      expect(find.text('Family Movies'), findsWidgets);
      expect(find.text('Documentary Movies'), findsWidgets);
      expect(find.text('Animation Movies'), findsWidgets);
      expect(find.text('Comedy Movies'), findsWidgets);
      expect(find.text('Horror Movies'), findsWidgets);
      expect(find.text('Drama Movies'), findsWidgets);
    });

    testWidgets('handles search functionality', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find and tap search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'test');
      await tester.pump(const Duration(milliseconds: 500)); // Wait for debounce

      // Verify search results are displayed
      expect(find.text('Movies'), findsOneWidget); // Tab label
      expect(find.text('People'), findsOneWidget); // Tab label
      expect(find.text('Test Movie 1'), findsWidgets);

      // Switch to People tab
      await tester.tap(find.text('People'));
      await tester.pumpAndSettle();

      expect(find.text('Test Actor'), findsOneWidget);
    });

    testWidgets('handles empty search results', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Mock empty search results
      when(mockTmdbApiService.searchMovie(any)).thenAnswer((_) async => []);
      when(mockTmdbApiService.searchPeople(any)).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Perform search
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('No movies found'), findsOneWidget);

      // Switch to People tab
      await tester.tap(find.text('People'));
      await tester.pumpAndSettle();

      expect(find.text('No people found'), findsOneWidget);
    });

    testWidgets('handles tablet layout correctly', (tester) async {
      // Set tablet dimensions
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify tablet-specific layouts
      // This will depend on your specific tablet layout implementation
      expect(find.text('Trending Movies'), findsOneWidget);
      expect(find.text('Recommended for You'), findsOneWidget);
    });
  });
}
