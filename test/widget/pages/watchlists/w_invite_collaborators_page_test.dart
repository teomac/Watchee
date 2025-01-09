import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/invite_collaborators_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_invite_collaborators_page_test.mocks.dart';

@GenerateMocks([UserService, WatchlistService])
void main() {
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late WatchList testWatchlist;
  late MyUser currentUser;
  late List<MyUser> testFollowedUsers;
  final now = DateTime.now().toString();

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();

    currentUser = MyUser(
      id: 'owner1',
      username: 'owner',
      name: 'Watchlist Owner',
      email: 'owner@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
      pendingInvites: {},
      collabWatchlists: {},
    );

    testFollowedUsers = [
      MyUser(
        id: '1',
        username: 'user1',
        name: 'User One',
        email: 'user1@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
      ),
      MyUser(
        id: '2',
        username: 'user2',
        name: 'User Two',
        email: 'user2@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
      ),
    ];

    testWatchlist = WatchList(
      id: 'watchlist1',
      userID: currentUser.id,
      name: 'Test Watchlist',
      isPrivate: false,
      movies: const [],
      followers: const [],
      collaborators: const [],
      createdAt: now,
      updatedAt: now,
    );

    when(mockUserService.getCurrentUser()).thenAnswer((_) async => currentUser);
    when(mockUserService.getFollowing(currentUser.id))
        .thenAnswer((_) async => testFollowedUsers);
    when(mockWatchlistService.inviteCollaborator(any, any, any))
        .thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
          Provider<WatchlistService>(create: (_) => mockWatchlistService),
        ],
        child: InviteCollaboratorsPage(watchlist: testWatchlist),
      ),
    );
  }

  testWidgets('displays loading state initially', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays followed users list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invite Collaborators'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(testFollowedUsers.length));

    for (var user in testFollowedUsers) {
      expect(find.text(user.username), findsOneWidget);
    }
  });

  testWidgets('handles empty followed users list', (WidgetTester tester) async {
    when(mockUserService.getFollowing(currentUser.id))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No users available to invite'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('invite button adds user to invited list',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final inviteButtons = find.byIcon(Icons.add);
    await tester.tap(inviteButtons.first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invitation sent to ${testFollowedUsers[0].username}'),
        findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
