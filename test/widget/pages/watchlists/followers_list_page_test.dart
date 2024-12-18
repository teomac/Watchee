import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/followers_list_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'followers_list_page_test.mocks.dart';

@GenerateMocks([UserService])
void main() {
  late MockUserService mockUserService;
  late WatchList testWatchlist;
  late List<MyUser> testFollowers;
  final now = DateTime.now().toString();

  setUp(() {
    mockUserService = MockUserService();

    testFollowers = [
      MyUser(
        id: '1',
        username: 'follower1',
        name: 'Follower One',
        email: 'follower1@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
        profilePicture: null, // Set to null to avoid image loading
      ),
      MyUser(
        id: '2',
        username: 'follower2',
        name: 'Follower Two',
        email: 'follower2@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
        profilePicture: null,
      ),
    ];

    testWatchlist = WatchList(
      id: 'watchlist1',
      userID: 'user1',
      name: 'Test Watchlist',
      isPrivate: false,
      movies: const [],
      followers: testFollowers.map((f) => f.id).toList(),
      collaborators: const [],
      createdAt: now,
      updatedAt: now,
    );

    // Setup mock behaviors
    for (var follower in testFollowers) {
      when(mockUserService.getUser(follower.id))
          .thenAnswer((_) async => follower);
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
        ],
        child: FollowersListPage(watchlist: testWatchlist),
      ),
    );
  }

  testWidgets('FollowersListPage displays loading state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FollowersListPage displays followers list correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Followers'), findsOneWidget);

    // Verify followers list
    expect(find.byType(ListTile), findsNWidgets(testFollowers.length));

    // Verify follower details
    for (var follower in testFollowers) {
      expect(find.text(follower.username), findsOneWidget);
      expect(find.text(follower.name), findsOneWidget);
    }

    // Verify CircleAvatar presence
    expect(find.byType(CircleAvatar), findsNWidgets(testFollowers.length));
  });

  testWidgets(
      'FollowersListPage displays default avatars when no profile pictures',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final avatars = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));

    for (var avatar in avatars) {
      expect(avatar.backgroundImage, isNull);
      expect(avatar.child, isNotNull);
    }
  });

  testWidgets('FollowersListPage handles empty followers list',
      (WidgetTester tester) async {
    testWatchlist = WatchList(
      id: 'watchlist1',
      userID: 'user1',
      name: 'Test Watchlist',
      isPrivate: false,
      movies: const [],
      followers: const [],
      collaborators: const [],
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('FollowersListPage handles error state',
      (WidgetTester tester) async {
    when(mockUserService.getUser(any)).thenThrow(Exception('Test error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('FollowersListPage displays correct number of followers',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(testWatchlist.followers.length));
  });
}
