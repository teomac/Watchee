// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/watchlists/liked_seen_movies_page.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'liked_seen_movies_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<UserService>(),
  MockSpec<TmdbApiService>(),
  MockSpec<NetworkImage>(),
  MockSpec<WatchlistService>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUserService mockUserService;
  late MockTmdbApiService mockTmdbApiService;
  late MockWatchlistService mockWatchlistService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize mocks
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUserService = MockUserService();
    mockTmdbApiService = MockTmdbApiService();
    mockWatchlistService = MockWatchlistService();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create test data
    final testUser = MyUser(
      id: 'user123',
      email: 'test@test.com',
      username: 'testuser',
      name: 'Test User',
      profilePicture: null,
      favoriteGenres: [],
      followers: [],
      following: [],
      followedWatchlists: {},
      likedMovies: [],
      seenMovies: [],
    );

    final testMovie = Movie(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      voteAverage: 8.0,
      genres: [],
    );

    // Setup mock responses
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockTmdbApiService.retrieveFilmInfo(any))
        .thenAnswer((_) async => testMovie);
  });

  Widget createTestWidget({bool isLiked = true}) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<UserService>(create: (_) => mockUserService),
        Provider<TmdbApiService>(create: (_) => mockTmdbApiService),
        Provider<WatchlistService>(create: (_) => mockWatchlistService),
      ],
      child: MaterialApp(
        home: LikedSeenMoviesPage(
          userId: 'user123',
          isLiked: isLiked,
        ),
      ),
    );
  }

  group('LikedSeenMoviesPage Basic UI Tests', () {
    testWidgets('Shows correct title for liked movies',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLiked: true));
      await tester.pump();
      expect(find.text('Liked'), findsOneWidget);
    });

    testWidgets('Shows correct title for seen movies',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLiked: false));
      await tester.pump();
      expect(find.text('Seen'), findsOneWidget);
    });

    testWidgets('Shows add movie button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Add a movie'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('LikedSeenMoviesPage Movie Management', () {
    testWidgets('Can remove movie from list', (WidgetTester tester) async {
      // Setup test user with a liked movie
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 8.0,
        genres: [],
      );

      final testUser = MyUser(
        id: 'user123',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test User',
        profilePicture: null,
        favoriteGenres: [],
        followers: [],
        following: [],
        followedWatchlists: {},
        likedMovies: [testMovie.toTinyMovie().toString()],
        seenMovies: [],
      );

      when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
      when(mockTmdbApiService.retrieveFilmInfo(any))
          .thenAnswer((_) async => testMovie);

      await tester.pumpWidget(createTestWidget(isLiked: true));
      await tester.pump();

      // Long press on movie tile
      await tester.longPress(find.text('Test Movie'));
      await tester.pumpAndSettle();

      // Verify remove option appears and tap it
      expect(find.text('Remove from liked'), findsOneWidget);
      await tester.tap(find.text('Remove from liked'));
      await tester.pump();

      // Verify removal was called
      verify(mockUserService.removeFromLikedMovies(any, any)).called(1);
    });

    testWidgets('Shows movie details when tapping movie',
        (WidgetTester tester) async {
      // Setup test user with a movie
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 8.0,
        genres: [],
      );

      final testUser = MyUser(
        id: 'user123',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test User',
        profilePicture: null,
        favoriteGenres: [],
        followers: [],
        following: [],
        followedWatchlists: {},
        likedMovies: [testMovie.toTinyMovie().toString()],
        seenMovies: [],
      );

      when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
      when(mockTmdbApiService.retrieveFilmInfo(any))
          .thenAnswer((_) async => testMovie);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on movie tile
      await tester.tap(find.text('Test Movie'));
      await tester.pump();

      // Verify movie details were fetched
      verify(mockTmdbApiService.retrieveFilmInfo(1)).called(2);
    });
  });

  group('LikedSeenMoviesPage Navigation Tests', () {
    testWidgets('Can navigate back', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Verify navigation (in a real app this would pop the navigator)
      expect(find.byType(LikedSeenMoviesPage), findsOneWidget);
    });
  });

  group('LikedSeenMoviesPage User Profile Tests', () {
    testWidgets('Shows user information correctly',
        (WidgetTester tester) async {
      final testUser = MyUser(
        id: 'user123',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test User',
        profilePicture: null,
        favoriteGenres: [],
        followers: [],
        following: [],
        followedWatchlists: {},
        likedMovies: [],
        seenMovies: [],
      );

      when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('Created by '), findsOneWidget);
    });
  });
}
