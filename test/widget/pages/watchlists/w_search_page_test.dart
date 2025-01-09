// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/search_page.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_search_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<UserService>(),
  MockSpec<WatchlistService>(),
  MockSpec<TmdbApiService>(),
  MockSpec<NetworkImage>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late MockTmdbApiService mockTmdbApiService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize mocks
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
    mockTmdbApiService = MockTmdbApiService();

    // Create test data
    final testMovie = Movie(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      voteAverage: 8.0,
      genres: [],
      releaseDate: '2023-01-01',
    );

    // Setup mock responses
    when(mockTmdbApiService.searchMovie(any))
        .thenAnswer((_) async => [testMovie]);
    when(mockWatchlistService.addMovieToWatchlist(any, any, any))
        .thenAnswer((_) async => {});
  });

  Widget createTestWidget(
      {WatchList? watchlist, String? userId, bool? isLiked}) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<UserService>(create: (_) => mockUserService),
        Provider<WatchlistService>(create: (_) => mockWatchlistService),
        Provider<TmdbApiService>(create: (_) => mockTmdbApiService),
      ],
      child: MaterialApp(
        home: SearchPage(
          watchlist: watchlist,
          userId: userId,
          isLiked: isLiked,
        ),
      ),
    );
  }

  group('SearchPage Basic UI Tests', () {
    testWidgets('Shows search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Movies'), findsOneWidget);
    });

    testWidgets('Shows back button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('SearchPage Search Functionality', () {
    testWidgets('Can enter search query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test Movie');
      await tester.pump();

      expect(find.text('Test Movie'), findsWidgets);
    });

    testWidgets('Shows search results', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500)); // Debounce delay

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('Can clear search query using X button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Test Movie');
      await tester.pumpAndSettle();

      // Verify the clear (X) button appears
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap the clear button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify the text field is empty
      expect(find.text('Test Movie'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('SearchPage Movie Management', () {
    testWidgets('Can add movie to watchlist', (WidgetTester tester) async {
      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [],
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      await tester.pumpWidget(createTestWidget(watchlist: testWatchlist));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify add was called
      verify(mockWatchlistService.addMovieToWatchlist(any, any, any)).called(1);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Can remove added movie', (WidgetTester tester) async {
      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [],
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      await tester.pumpWidget(createTestWidget(watchlist: testWatchlist));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      // Add movie first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Then remove it
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      verify(mockWatchlistService.removeMovieFromWatchlist(any, any, any))
          .called(1);
    });
  });

  group('SearchPage Liked/Seen Movies', () {
    testWidgets('Can add movie to liked movies', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        userId: 'user123',
        isLiked: true,
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      verify(mockUserService.addToLikedMovies(any, any)).called(1);
    });

    testWidgets('Can add movie to seen movies', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        userId: 'user123',
        isLiked: false,
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      verify(mockUserService.addToSeenMovies(any, any)).called(1);
    });
  });

  group('SearchPage Navigation', () {
    testWidgets('Can navigate to movie details', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Verify navigation occurred
      verify(mockTmdbApiService.retrieveFilmInfo(any)).called(1);
    });
  });

  group('SearchPage Error Handling', () {
    testWidgets('Shows error message on failed add',
        (WidgetTester tester) async {
      when(mockWatchlistService.addMovieToWatchlist(any, any, any))
          .thenThrow(Exception('Failed to add movie'));

      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [],
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      await tester.pumpWidget(createTestWidget(watchlist: testWatchlist));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to add movie to watchlist'), findsOneWidget);
    });
  });
}
