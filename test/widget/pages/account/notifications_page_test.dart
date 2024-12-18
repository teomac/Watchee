import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/account/notifications_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'notifications_page_test.mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([
  UserService,
  WatchlistService,
  FirebaseFirestore,
])
void main() {
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late MyUser testUser;
  late List<Map<String, dynamic>> testNotifications;

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();

    testUser = MyUser(
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    testNotifications = [
      {
        'notificationId': '1',
        'type': 'new_follower',
        'message': 'User1 started following you',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 15, 14, 30)),
        'followerId': 'user1Id'
      },
      {
        'notificationId': '2',
        'type': 'new_review',
        'message': 'User2 reviewed Movie1',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 15, 14, 30)),
        'reviewAuthorId': 'user2Id'
      },
      {
        'notificationId': '3',
        'type': 'new_invitation',
        'message': 'User3 invited you to collaborate on Watchlist1',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 15, 14, 30)),
        'watchlistId': 'watchlist1',
        'watchlistOwner': 'user3Id'
      }
    ];

    // Setup mock behaviors
    when(mockUserService.getNotifications(any))
        .thenAnswer((_) async => testNotifications);
    when(mockUserService.getUser(any)).thenAnswer(
        // ignore: no_wildcard_variable_uses
        (_) async => testUser.copyWith(id: _.positionalArguments[0]));
    when(mockUserService.clearNotifications(any)).thenAnswer((_) async => {});
    when(mockUserService.removeNotification(any, any))
        .thenAnswer((_) async => {});
    when(mockWatchlistService.acceptInvite(any, any, any))
        .thenAnswer((_) async => {});
    when(mockWatchlistService.declineInvite(any, any, any))
        .thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
          Provider<WatchlistService>(create: (_) => mockWatchlistService),
        ],
        child: NotificationsPage(user: testUser),
      ),
    );
  }

  testWidgets('NotificationsPage displays notifications correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Notifications'), findsOneWidget);

    // Verify notifications are displayed
    expect(find.text('User1 started following you'), findsOneWidget);
    expect(find.text('User2 reviewed Movie1'), findsOneWidget);
    expect(find.text('User3 invited you to collaborate on Watchlist1'),
        findsOneWidget);

    // Verify icons are present
    expect(find.byIcon(Icons.person_add), findsOneWidget); // new follower icon
    expect(find.byIcon(Icons.comment), findsOneWidget); // new review icon
    expect(
        find.byIcon(Icons.playlist_add), findsOneWidget); // new invitation icon
  });

  testWidgets('Clear all notifications works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open menu and tap clear all
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all notifications'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Clear All Notifications'), findsOneWidget);
    expect(find.text('Are you sure you want to clear all notifications?'),
        findsOneWidget);

    // Confirm clearing
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Verify service was called
    verify(mockUserService.clearNotifications(testUser.id)).called(1);
  });

  testWidgets('Dismissing a notification works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Reset the mock to clear initial calls
    reset(mockUserService);
    when(mockUserService.getNotifications(any))
        .thenAnswer((_) async => testNotifications);
    when(mockUserService.removeNotification(any, any))
        .thenAnswer((_) async => {});

    // Perform dismiss gesture (swipe left with negative offset)
    await tester.drag(
        find.text('User1 started following you'), const Offset(-500, 0));
    await tester.pump(); // Start the dismiss animation
    await tester
        .pump(const Duration(milliseconds: 300)); // Wait for half of animation
    await tester
        .pump(const Duration(milliseconds: 300)); // Complete the animation
    await tester.pumpAndSettle(); // Wait for any remaining animations

    // Verify service was called
    verify(mockUserService.removeNotification(testUser.id, '1')).called(1);

    // Verify snackbar appears
    expect(find.text('Notification dismissed'), findsOneWidget);
  });

  testWidgets('Accept invitation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find and tap accept button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Accept').first);
    await tester.pumpAndSettle();

    // Verify services were called
    verify(mockWatchlistService.acceptInvite('watchlist1', 'user3Id', '1'))
        .called(1);
    verify(mockUserService.removeNotification(testUser.id, '3')).called(1);
  });

  testWidgets('Decline invitation works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find and tap decline button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Decline').first);
    await tester.pumpAndSettle();

    // Verify services were called
    verify(mockWatchlistService.declineInvite('watchlist1', 'user3Id', '1'))
        .called(1);
    verify(mockUserService.removeNotification(testUser.id, '3')).called(1);
  });

  testWidgets('Pull to refresh works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Perform refresh gesture
    await tester.drag(
        find.text('User1 started following you'), const Offset(0, 300));
    await tester.pumpAndSettle();

    // Verify notifications were fetched again
    verify(mockUserService.getNotifications(testUser.id))
        .called(2); // Once for initial load, once for refresh
  });

  testWidgets('Empty state is displayed correctly',
      (WidgetTester tester) async {
    // Setup empty notifications
    when(mockUserService.getNotifications(any))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify empty state message
    expect(find.text('No notifications'), findsOneWidget);
  });
}
