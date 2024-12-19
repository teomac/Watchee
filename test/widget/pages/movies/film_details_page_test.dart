// ignore_for_file: deprecated_member_use

import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'film_details_page_test.mocks.dart';

@GenerateMocks([
  TmdbApiService,
  UserService,
  WatchlistService,
])
void main() {
  late MockTmdbApiService mockTmdbApiService;
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late Movie testMovie;
  late MyUser testUser;

  setUp(() {
    mockTmdbApiService = MockTmdbApiService();
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();

    testMovie = Movie(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
      genres: ['Action', 'Drama'],
      runtime: 120,
      tagline: 'Test Tagline',
    );

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

    // Setup common mock responses
    when(mockTmdbApiService.retrieveFilmInfo(any))
        .thenAnswer((_) async => testMovie);
    when(mockTmdbApiService.retrieveTrailer(any)).thenAnswer((_) async => '');
    when(mockTmdbApiService.retrieveCast(any)).thenAnswer((_) async => []);
    when(mockTmdbApiService.fetchAllProviders(any))
        .thenAnswer((_) async => {'US': []});
    when(mockTmdbApiService.fetchRecommendedMovies(any))
        .thenAnswer((_) async => []);

    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getFriendsReviews(any, any))
        .thenAnswer((_) async => []);
    when(mockUserService.getLikedMovieIds(any)).thenAnswer((_) async => []);
    when(mockUserService.getSeenMovieIds(any)).thenAnswer((_) async => []);
    when(mockUserService.addMovieReview(any, any, any, any, any, any))
        .thenAnswer((_) async => {});

    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<TmdbApiService>.value(value: mockTmdbApiService),
          Provider<UserService>.value(value: mockUserService),
          Provider<WatchlistService>.value(value: mockWatchlistService),
        ],
        child: FilmDetailsPage(movie: testMovie),
      ),
    );
  }

  group('FilmDetailsPage Widget Tests', () {
    testWidgets('renders basic movie information correctly', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      // Need to pump and settle multiple times due to multiple async operations
      await tester.pump();

      // Verify movie details are displayed
      expect(find.text('Test Movie', findRichText: true), findsWidgets);
      expect(find.text('Test Overview'), findsOneWidget);
      expect(find.text('Test Tagline'), findsOneWidget);

      // Verify genres
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Drama'), findsOneWidget);

      // Verify basic UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('handles add to watchlist functionality', (tester) async {
      final testWatchlist = WatchList(
        createdAt: '',
        updatedAt: '',
        id: 'test_watchlist_id',
        name: 'Test Watchlist',
        userID: testUser.id,
        movies: [],
        collaborators: [],
        isPrivate: false,
      );

      when(mockWatchlistService.getOwnWatchLists(any))
          .thenAnswer((_) async => [testWatchlist]);

      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify modal bottom sheet appears
      expect(find.text('My Lists'), findsOneWidget);
      expect(find.text('Test Watchlist'), findsOneWidget);
      expect(find.text('Liked movies'), findsOneWidget);
      expect(find.text('Seen movies'), findsOneWidget);
    });

    testWidgets('displays friends reviews correctly', (tester) async {
      final testReview = MovieReview(
          id: 'test_review_id',
          userId: 'friend_id',
          movieId: testMovie.id,
          text: 'Amazing movie!',
          rating: 5,
          timestamp: Timestamp.now(),
          title: testMovie.title,
          username: 'friend_username');

      when(mockUserService.getFriendsReviews(any, any))
          .thenAnswer((_) async => [testReview]);

      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Amazing movie!'), findsOneWidget);
      expect(find.text('friend_username'), findsOneWidget);
    });

    testWidgets('handles loading state correctly', (tester) async {
      // Make the API calls take some time
      when(mockTmdbApiService.retrieveFilmInfo(any)).thenAnswer((_) async =>
          Future.delayed(const Duration(milliseconds: 100), () => testMovie));

      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for loading to complete
      await tester.pump();

      // Verify content is shown
      expect(find.byType(CircularProgressIndicator), findsOne);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Test Movie', findRichText: true), findsWidgets);
    });
  });

  testWidgets('submits review successfully', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Find and fill review field
    final reviewField = find.byType(TextField);
    expect(reviewField, findsOneWidget);
    await tester.enterText(reviewField, 'Great movie!');
    await tester.pump();

    // Select rating
    final starButtons = find.byIcon(Icons.star);
    await tester.tap(starButtons.first);
    await tester.pump();

    // Submit review
    final submitButton =
        find.widgetWithText(ElevatedButton, 'Submit your review');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pump(const Duration(milliseconds: 2000));

    // Verify success message
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('shows cast section correctly', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final castList = [
      {
        'id': 1,
        'name': 'John Doe',
        'character': 'Main Character',
      }
    ];

    when(mockTmdbApiService.retrieveCast(any))
        .thenAnswer((_) async => castList);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Cast'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Main Character'), findsOneWidget);
  });

  testWidgets('displays streaming providers correctly', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final providers = {
      'US': [
        {'provider_name': 'Netflix'}
      ]
    };

    when(mockTmdbApiService.fetchAllProviders(any))
        .thenAnswer((_) async => providers);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Available On'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('handles empty review submission', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Try to submit empty review
    final submitButton =
        find.widgetWithText(ElevatedButton, 'Submit your review');

    expect(submitButton, findsOneWidget);
    //submit button is disabled
    expect(tester.widget<ElevatedButton>(submitButton).enabled, false);
  });

  testWidgets('displays no reviews message when no friends reviews',
      (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    when(mockUserService.getFriendsReviews(any, any))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(
        find.text('No reviews from followed users available.'), findsOneWidget);
  });

  testWidgets('handles provider country selection', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    when(mockTmdbApiService.fetchAllProviders(any)).thenAnswer((_) async => {
          'US': [
            {'provider_name': 'Netflix'}
          ],
          'UK': [
            {'provider_name': 'Prime'}
          ]
        });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Find and tap country dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();

    // Select UK
    await tester.tap(find.text('UK').last);
    await tester.pump();

    expect(find.text('Prime'), findsOneWidget);
  });

  testWidgets('shows error handling for failed review submission',
      (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    when(mockUserService.addMovieReview(any, any, any, any, any, any))
        .thenThrow(Exception('Failed to submit review'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Try to submit empty review
    await tester.tap(find.text('Submit your review'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.enabled, false);
  });

  testWidgets('handles movie cast display', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    when(mockTmdbApiService.retrieveCast(any)).thenAnswer((_) async => [
          {
            'id': 1,
            'name': 'Actor Name',
            'character': 'Character Name',
          }
        ]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Actor Name'), findsOneWidget);
    expect(find.text('Character Name'), findsOneWidget);
  });

  testWidgets('shows recommended movies section', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final recommendedMovie = Movie(
      id: 2,
      title: 'Recommended Movie',
      overview: 'Overview',
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genres: ['Action'],
    );

    when(mockTmdbApiService.fetchRecommendedMovies(any))
        .thenAnswer((_) async => [recommendedMovie]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('You may also like'), findsOneWidget);
    expect(find.text('Recommended Movie'), findsOneWidget);
  });
}
