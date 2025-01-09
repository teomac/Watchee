import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/collaborators_list_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_collaborators_list_page_test.mocks.dart';

@GenerateMocks([UserService])
void main() {
  late MockUserService mockUserService;
  late WatchList testWatchlist;
  late List<MyUser> testCollaborators;
  final now = DateTime.now().toString();

  setUp(() {
    mockUserService = MockUserService();

    testCollaborators = [
      MyUser(
        id: '1',
        username: 'collaborator1',
        name: 'Collaborator One',
        email: 'collaborator1@test.com',
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
        username: 'collaborator2',
        name: 'Collaborator Two',
        email: 'collaborator2@test.com',
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
      followers: const [],
      collaborators: testCollaborators.map((f) => f.id).toList(),
      createdAt: now,
      updatedAt: now,
    );

    // Setup mock behaviors
    for (var collaborator in testCollaborators) {
      when(mockUserService.getUser(collaborator.id))
          .thenAnswer((_) async => collaborator);
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
        ],
        child: CollaboratorsListPage(watchlist: testWatchlist),
      ),
    );
  }

  testWidgets('CollaboratorsListPage displays loading state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CollaboratorsListPage displays collaborators list correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Collaborators'), findsOneWidget);

    // Verify collaborators list
    expect(find.byType(ListTile), findsNWidgets(testCollaborators.length));

    // Verify collaborator details
    for (var collaborator in testCollaborators) {
      expect(find.text(collaborator.username), findsOneWidget);
      expect(find.text(collaborator.name), findsOneWidget);
    }

    // Verify CircleAvatar presence
    expect(find.byType(CircleAvatar), findsNWidgets(testCollaborators.length));
  });

  testWidgets(
      'CollaboratorsListPage displays default avatars when no profile pictures',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final avatars = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));

    for (var avatar in avatars) {
      expect(avatar.backgroundImage, isNull);
      expect(avatar.child, isNotNull);
    }
  });

  testWidgets('CollaboratorsListPage handles empty collaborators list',
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

  testWidgets('CollaboratorsListPage handles error state',
      (WidgetTester tester) async {
    when(mockUserService.getUser(any)).thenThrow(Exception('Test error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('CollaboratorsListPage displays correct number of collaborators',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(testWatchlist.collaborators.length));
  });
}
