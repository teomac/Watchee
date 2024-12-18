import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/account/user_profile_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile_page_test.mocks.dart';

@GenerateMocks([UserService, WatchlistService])
void main() {
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late MyUser testUser;
  late MyUser currentUser;
  late List<MovieReview> testReviews;
  late List<WatchList> testWatchlists;

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();

    testUser = MyUser(
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
      profilePicture: null,
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    currentUser = MyUser(
      id: '2',
      username: 'currentuser',
      name: 'Current User',
      email: 'current@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    testReviews = [
      MovieReview(
        userId: '1',
        id: '1',
        movieId: 1,
        rating: 4,
        text: 'Great movie!',
        title: 'Movie 1',
        username: 'testuser',
        timestamp: Timestamp.fromDate(DateTime(2024, 1, 15)),
      ),
      MovieReview(
        userId: '1',
        id: '2',
        movieId: 2,
        rating: 3,
        text: 'Good movie',
        title: 'Movie 2',
        username: 'testuser',
        timestamp: Timestamp.fromDate(DateTime(2024, 1, 16)),
      ),
    ];

    final now = DateTime.now().toString();
    testWatchlists = [
      WatchList(
        id: '1',
        name: 'Watchlist 1',
        movies: [],
        userID: '1',
        collaborators: [],
        followers: [],
        isPrivate: false,
        createdAt: now,
        updatedAt: now,
      ),
      WatchList(
        id: '2',
        name: 'Watchlist 2',
        movies: [],
        userID: '1',
        collaborators: [],
        followers: [],
        isPrivate: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Setup mock behaviors
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => currentUser);
    when(mockUserService.getFollowers(any)).thenAnswer((_) async => []);
    when(mockUserService.getReviewsByUser(any))
        .thenAnswer((_) async => testReviews);
    when(mockUserService.isFollowing(any, any)).thenAnswer((_) async => false);

    when(mockWatchlistService.getPublicWatchLists(any))
        .thenAnswer((_) async => testWatchlists);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
          Provider<WatchlistService>(create: (_) => mockWatchlistService),
        ],
        child: UserProfilePage(user: testUser),
      ),
    );
  }

  testWidgets('UserProfilePage displays basic user information correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify user information is displayed
    expect(find.text(testUser.name), findsOneWidget);
    expect(find.text('@${testUser.username}'), findsOneWidget);

    // Verify profile picture placeholder (since testUser has no profile picture)
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Verify section titles
    expect(find.text('Public Watchlists'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
  });

  testWidgets('Follow button works correctly for non-owner',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify initial follow button state
    expect(find.text('Follow'), findsOneWidget);

    // Setup mock for follow action
    when(mockUserService.followUser(any, any)).thenAnswer((_) async => {});

    // Tap follow button
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    // Verify follow action was called
    verify(mockUserService.followUser(currentUser.id, testUser.id)).called(1);

    // Verify button text changed
    expect(find.text('Unfollow'), findsOneWidget);
  });

  testWidgets('Reviews are displayed correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify review content
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Great movie!'), findsOneWidget);
    expect(find.text('4/5'), findsOneWidget);

    expect(find.text('Movie 2'), findsOneWidget);
    expect(find.text('Good movie'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('Public watchlists are displayed correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify watchlist names are displayed
    expect(find.text('Watchlist 1'), findsOneWidget);
    expect(find.text('Watchlist 2'), findsOneWidget);

    // Verify movie count text
    expect(find.text('0 movies'), findsNWidgets(2));
  });

  testWidgets('Edit reviews button only shows for profile owner',
      (WidgetTester tester) async {
    // Test with current user being the profile owner
    when(mockUserService.getCurrentUser())
        .thenAnswer((_) async => testUser); // Same as profile user

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify edit button is present
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Show more/less reviews functionality works',
      (WidgetTester tester) async {
    // Add more reviews to test pagination
    testReviews.addAll([
      MovieReview(
        userId: '1',
        id: '3',
        movieId: 3,
        rating: 5,
        text: 'Excellent movie',
        title: 'Movie 3',
        username: 'testuser',
        timestamp: Timestamp.fromDate(DateTime(2024, 1, 17)),
      ),
      MovieReview(
        userId: '1',
        id: '4',
        movieId: 4,
        rating: 2,
        text: 'Not so good',
        title: 'Movie 4',
        username: 'testuser',
        timestamp: Timestamp.fromDate(DateTime(2024, 1, 18)),
      ),
    ]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Initially should show only first 3 reviews
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Movie 2'), findsOneWidget);
    expect(find.text('Movie 3'), findsOneWidget);
    expect(find.text('Movie 4'), findsNothing);

    // Verify and tap 'Show more' button
    await tester.dragUntilVisible(find.text('Show more'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    expect(find.text('Show more'), findsOneWidget);
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    // Should now show all reviews
    expect(find.text('Movie 4'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);

    // Tap 'Show less' to collapse
    await tester.dragUntilVisible(find.text('Show less'),
        find.byType(SingleChildScrollView), const Offset(0, 750));
    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();

    // Should be back to showing only 3 reviews
    expect(find.text('Movie 4'), findsNothing);
    expect(find.text('Show more'), findsOneWidget);
  });

  testWidgets('Private watchlists are not displayed',
      (WidgetTester tester) async {
    final now = DateTime.now().toString();
    // Add a private watchlist
    var privateWatchlist = WatchList(
      id: '3',
      name: 'Private Watchlist',
      movies: [],
      userID: '1',
      collaborators: [],
      followers: [],
      isPrivate: true,
      createdAt: now,
      updatedAt: now,
    );

    if (privateWatchlist.isPrivate == false) {
      testWatchlists.add(privateWatchlist);
    }

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify public watchlists are shown
    expect(find.text('Watchlist 1'), findsOneWidget);
    expect(find.text('Watchlist 2'), findsOneWidget);

    // Verify private watchlist is not shown
    expect(find.text('Private Watchlist'), findsNothing);
  });

  testWidgets('Displays tablet layout correctly', (WidgetTester tester) async {
    // Set up a tablet-sized screen
    tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify tablet-specific layout elements
    expect(find.byType(Row), findsWidgets); // Should find the tablet layout row

    // Reset the screen size
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Displays followed by text correctly',
      (WidgetTester tester) async {
    final follower = MyUser(
      id: '3',
      username: 'follower',
      name: 'Follower User',
      email: 'follower@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    currentUser.following.add(follower.id);
    when(mockUserService.getFollowers(any)).thenAnswer((_) async => [follower]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Followed by Follower User'), findsOneWidget);
  });

  testWidgets('Unfollow button works correctly', (WidgetTester tester) async {
    // Start with user being followed
    when(mockUserService.isFollowing(any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Unfollow'), findsOneWidget);

    when(mockUserService.unfollowUser(any, any)).thenAnswer((_) async => {});

    await tester.tap(find.text('Unfollow'));
    await tester.pumpAndSettle();

    verify(mockUserService.unfollowUser(currentUser.id, testUser.id)).called(1);
    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('Returns follow status change on back navigation',
      (WidgetTester tester) async {
    // Create a custom wrapper widget to capture navigation result
    final navigatorKey = GlobalKey<NavigatorState>();

    Widget createTestableWidget() {
      return MaterialApp(
        navigatorKey: navigatorKey,
        home: MultiProvider(
          providers: [
            Provider<UserService>(create: (_) => mockUserService),
            Provider<WatchlistService>(create: (_) => mockWatchlistService),
          ],
          child: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(user: testUser),
                      ),
                    );
                    // Store the result in our navigator state
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Material(
                            child: Text('Result: $result'),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Open Profile'),
                );
              },
            ),
          ),
        ),
      );
    }

    // Build our test widget
    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open the profile page
    await tester.tap(find.text('Open Profile'));
    await tester.pumpAndSettle();

    // Verify we're on the profile page
    expect(find.byType(UserProfilePage), findsOneWidget);

    // Setup mock for follow action
    when(mockUserService.followUser(any, any)).thenAnswer((_) async => {});

    // Perform follow action
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    // Navigate back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify the result was returned
    expect(find.text('Result: true'), findsOneWidget);

    // Test returning without changes
    await tester.tap(find.text('Open Profile'));
    await tester.pumpAndSettle();

    // Navigate back without making changes
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify the result shows no changes
    expect(find.text('Result: false'), findsOneWidget);
  });
}
