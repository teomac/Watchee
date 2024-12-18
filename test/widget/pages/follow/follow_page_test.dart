import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/follow/follow_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'follow_page_test.mocks.dart';

@GenerateMocks([UserService])
void main() {
  late MockUserService mockUserService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockUserService = MockUserService();

    final testUser = MyUser(
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
      favoriteGenres: [],
      following: ['2', '3'],
      followers: ['4', '5'],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    final testFollowing = [
      MyUser(
        id: '2',
        username: 'following1',
        name: 'Following One',
        email: 'following1@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
      ),
      MyUser(
        id: '3',
        username: 'following2',
        name: 'Following Two',
        email: 'following2@test.com',
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
      ),
    ];

    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.getFollowing(any))
        .thenAnswer((_) async => testFollowing);
    when(mockUserService.getFollowers(any)).thenAnswer((_) async => []);
  });

  testWidgets('FollowView shows basic UI elements',
      (WidgetTester tester) async {
    final widget = MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(
            create: (_) => mockUserService,
          ),
        ],
        child: const FollowView(),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
  });
}
