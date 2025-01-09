// ignore_for_file: deprecated_member_use

import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/pages/watchlists/my_lists.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../mocks/w_my_lists_test.mocks.dart';

@GenerateMocks([
  WatchlistService,
  UserService,
  FirebaseFirestore,
  CustomAuth,
  NotificationsService,
])
void main() {
  late MockWatchlistService mockWatchlistService;
  late MockUserService mockUserService;
  late MyUser testUser;
  late WatchList testWatchlist;
  late MockCustomAuth mockCustomAuth;
  late MockNotificationsService mockNotificationsService;

  setUp(() {
    mockWatchlistService = MockWatchlistService();
    mockUserService = MockUserService();
    mockCustomAuth = MockCustomAuth();
    mockNotificationsService = MockNotificationsService();
    SharedPreferences.setMockInitialValues({});

    testUser = MyUser(
      id: 'test-user-id',
      name: 'Test User',
      username: 'testuser',
      email: 'test@test.com',
      profilePicture: null,
      favoriteGenres: [],
      followers: [],
      following: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    testWatchlist = WatchList(
      id: 'test-watchlist-id',
      name: 'Test Watchlist',
      userID: testUser.id,
      movies: [],
      followers: [],
      collaborators: [],
      isPrivate: false,
      createdAt: '2020-01-01',
      updatedAt: '2020-01-01',
    );
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<WatchlistService>(
            create: (_) => mockWatchlistService,
          ),
          Provider<UserService>(
            create: (_) => mockUserService,
          ),
          Provider<CustomAuth>(
            create: (_) => mockCustomAuth,
          ),
          Provider<NotificationsService>(
            create: (_) => mockNotificationsService,
          ),
        ],
        child: const MyLists(),
      ),
    );
  }

  testWidgets('MyLists shows empty state when no watchlists exist',
      (WidgetTester tester) async {
    // Arrange
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    // Add mock for notifications unread count
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump(); // Wait for first frame
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    expect(find.text('Press the + button to create your first watchlist'),
        findsOneWidget);
    expect(find.text('Followed watchlists will appear here'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('MyLists shows watchlist when they exist',
      (WidgetTester tester) async {
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => [testWatchlist]);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Test Watchlist'), findsOneWidget);
    expect(find.text('0 movies · testuser'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Create watchlist dialog shows and works correctly',
      (WidgetTester tester) async {
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.createWatchList(any, any, any))
        .thenAnswer((_) async => {});
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap the FAB to show dialog
    await tester.tap(find.byKey(const Key('add_watchlist_button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert dialog is shown
    expect(find.text('Create New Watchlist'), findsOneWidget);
    expect(find.text('Private Watchlist'), findsOneWidget);

    // Enter watchlist name
    await tester.enterText(find.byType(TextFormField), 'New Watchlist');
    await tester.pump();

    // Tap create button
    await tester.tap(find.text('Create'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify create was called
    verify(mockWatchlistService.createWatchList(
            testUser, 'New Watchlist', false))
        .called(1);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Sort options work correctly', (WidgetTester tester) async {
    final watchlists = [
      testWatchlist,
      testWatchlist.copyWith(
        id: 'test-watchlist-2',
        name: 'Another Watchlist',
        movies: ['movie1', 'movie2'],
      ),
    ];

    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => watchlists);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Open sort menu
    await tester.tap(find.text('Latest Added').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert sort options are shown
    expect(find.text('Sort by Name'), findsOneWidget);
    expect(find.text('Sort by Movie Count'), findsOneWidget);
    expect(find.text('Sort by Latest Edit'), findsOneWidget);

    // Test name sort
    await tester.tap(find.text('Sort by Name'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify watchlists are sorted by name
    final listItems = find.byType(ListTile);
    expect(
        listItems, findsNWidgets(4)); // Including Liked and Seen Movies tiles
    expect(find.text('Another Watchlist'), findsOneWidget);
    expect(find.text('Test Watchlist'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Delete watchlist works correctly', (WidgetTester tester) async {
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => [testWatchlist]);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.deleteWatchList(any)).thenAnswer((_) async => {});
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Long press to show options
    await tester.longPress(find.text('Test Watchlist'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap delete option
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Confirm deletion
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify delete was called
    verify(mockWatchlistService.deleteWatchList(testWatchlist)).called(1);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  });

  testWidgets('Liked and Seen movies sections work correctly',
      (WidgetTester tester) async {
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getUser(any)).thenAnswer((_) async => testUser);
    when(mockWatchlistService.getOwnWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getCollabWatchLists(any))
        .thenAnswer((_) async => []);
    when(mockWatchlistService.getFollowingWatchlists(any))
        .thenAnswer((_) async => []);
    when(mockNotificationsService.unreadCount).thenReturn(0);

    // Set a reasonable screen size
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert sections exist
    expect(find.text('Liked Movies'), findsOneWidget);
    expect(find.text('Seen Movies'), findsOneWidget);
    expect(find.text('All your favorite movies in one place'), findsOneWidget);
    expect(find.text('Movies you have already watched'), findsOneWidget);
  });
}
