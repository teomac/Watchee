// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
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
import 'manage_watchlist_page_test.mocks.dart';

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

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize mocks
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
    mockTmdbApiService = MockTmdbApiService();

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

    final testWatchlist = WatchList(
      id: 'watchlist123',
      name: 'Test Watchlist',
      userID: 'user123',
      movies: [], // Empty movies list to avoid image loading
      isPrivate: false,
      followers: [],
      collaborators: [],
      createdAt: '2020-01-01',
      updatedAt: '2020-01-01',
    );

    // Setup mock responses
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getWatchList(any, any))
        .thenAnswer((_) async => testWatchlist);
    when(mockTmdbApiService.retrieveFilmInfo(any))
        .thenAnswer((_) async => testMovie);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<UserService>(create: (_) => mockUserService),
        Provider<WatchlistService>(create: (_) => mockWatchlistService),
        Provider<TmdbApiService>(create: (_) => mockTmdbApiService),
      ],
      child: const MaterialApp(
        home: ManageWatchlistPage(
          userId: 'user123',
          watchlistId: 'watchlist123',
        ),
      ),
    );
  }

  group('ManageWatchlistPage Basic UI Tests', () {
    testWidgets('Shows watchlist title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Test Watchlist'), findsWidgets);
    });

    testWidgets('Shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.sort), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });

  group('ManageWatchlistPage Owner Actions', () {
    testWidgets('Shows add movie button for owner',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.text('Add a movie'), findsOneWidget);
    });

    testWidgets('Can open options menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Rename watchlist'), findsOneWidget);
    });
  });

  group('ManageWatchlistPage BLoC Tests', () {
    testWidgets('Can toggle watchlist privacy', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 900);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Open options menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap on privacy toggle
      await tester.tap(find.text('Make it private'));
      await tester.pump();

      // Verify the BLoC received the event
      verify(mockWatchlistService.updateWatchList(any)).called(1);
    });

    testWidgets('Can rename watchlist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Open options menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap on rename option
      await tester.tap(find.text('Rename watchlist'));
      await tester.pump();

      // Verify dialog appears
      expect(find.text('Rename Watchlist'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter new name
      await tester.enterText(find.byType(TextField), 'New Watchlist Name');
      await tester.pump();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify the BLoC received the event
      verify(mockWatchlistService.updateWatchList(any)).called(1);
    });
  });

  group('ManageWatchlistPage Movie Management', () {
    testWidgets('Can remove movie from watchlist', (WidgetTester tester) async {
      // Setup mock watchlist with a movie
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 8.0,
        genres: [],
      ).toTinyMovie().toString();

      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [testMovie],
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      when(mockWatchlistService.getWatchList(any, any))
          .thenAnswer((_) async => testWatchlist);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Long press on movie tile
      await tester.longPress(find.text('Test Movie'));
      await tester.pumpAndSettle();

      // Verify remove option appears and tap it
      expect(find.text('Remove from Test Watchlist'), findsOneWidget);
      await tester.tap(find.text('Remove from Test Watchlist'));
      await tester.pump();

      // Verify removal was called
      verify(mockWatchlistService.removeMovieFromWatchlist(any, any, any))
          .called(1);
    });

    testWidgets('Shows movie details when tapping movie',
        (WidgetTester tester) async {
      // Setup mock watchlist with a movie
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        voteAverage: 8.0,
        genres: [],
      ).toTinyMovie().toString();

      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [testMovie],
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      when(mockWatchlistService.getWatchList(any, any))
          .thenAnswer((_) async => testWatchlist);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on movie tile
      await tester.tap(find.text('Test Movie'));
      await tester.pump();

      // Verify movie details were fetched
      verify(mockTmdbApiService.retrieveFilmInfo(1)).called(2);
    });
  });

  group('ManageWatchlistPage Sorting Tests', () {
    testWidgets('Can sort movies by different criteria',
        (WidgetTester tester) async {
      // Setup mock watchlist with multiple movies
      final movies = [
        Movie(
                id: 1,
                title: 'A Movie',
                overview: 'Test',
                voteAverage: 8.0,
                genres: [],
                releaseDate: '2023-01-01')
            .toTinyMovie()
            .toString(),
        Movie(
                id: 2,
                title: 'B Movie',
                overview: 'Test',
                voteAverage: 8.0,
                genres: [],
                releaseDate: '2023-02-01')
            .toTinyMovie()
            .toString(),
      ];

      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: movies,
        isPrivate: false,
        followers: [],
        collaborators: [],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      when(mockWatchlistService.getWatchList(any, any))
          .thenAnswer((_) async => testWatchlist);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Open sort menu
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Verify sort options are present
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Release Date'), findsOneWidget);
      expect(find.text('Latest Added'), findsOneWidget);

      // Test sorting by name
      await tester.tap(find.text('Name'));
      await tester.pump();

      // Verify movies are sorted
      final movieTiles = find.byType(ListTile);
      expect(tester.widget<ListTile>(movieTiles.at(0)).title, isA<Text>());
      expect((tester.widget<ListTile>(movieTiles.at(0)).title as Text).data,
          'A Movie');
    });
  });

  group('ManageWatchlistPage Collaborator Tests', () {
    testWidgets('Shows invite collaborator option for owner',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Open options menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Invite as collaborator'), findsOneWidget);
    });

    testWidgets('Shows collaborator count', (WidgetTester tester) async {
      final testWatchlist = WatchList(
        id: 'watchlist123',
        name: 'Test Watchlist',
        userID: 'user123',
        movies: [],
        isPrivate: false,
        followers: [],
        collaborators: ['collaborator1'],
        createdAt: '2020-01-01',
        updatedAt: '2020-01-01',
      );

      when(mockWatchlistService.getWatchList(any, any))
          .thenAnswer((_) async => testWatchlist);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('and'), findsOneWidget);
    });
  });
}
