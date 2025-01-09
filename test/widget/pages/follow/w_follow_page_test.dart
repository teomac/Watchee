import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/follow/follow_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/notifications_service.dart';

@GenerateNiceMocks([
  MockSpec<UserService>(),
  MockSpec<CustomAuth>(),
  MockSpec<NotificationsService>()
])
import '../../../mocks/w_follow_page_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockCustomAuth mockAuth;
  late MockNotificationsService mockNotificationsService;

  setUp(() {
    mockUserService = MockUserService();
    mockAuth = MockCustomAuth();
    mockNotificationsService = MockNotificationsService();
  });

  final currentUser = MyUser(
    id: '1',
    username: 'test_user',
    name: 'Test User',
    email: 'test@test.com',
    favoriteGenres: [],
    following: [],
    followers: [],
    likedMovies: [],
    seenMovies: [],
    followedWatchlists: {},
  );

  final testFollowing = [
    MyUser(
      id: '2',
      username: 'following_user',
      name: 'Following User',
      email: 'following@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    )
  ];

  final testFollowers = [
    MyUser(
      id: '3',
      username: 'follower_user',
      name: 'Follower User',
      email: 'follower@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    )
  ];

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<UserService>.value(value: mockUserService),
        Provider<CustomAuth>.value(value: mockAuth),
        Provider<NotificationsService>.value(value: mockNotificationsService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: FollowView(),
        ),
      ),
    );
  }

  void setupMockResponses({
    List<MyUser>? following,
    List<MyUser>? followers,
    bool throwError = false,
  }) {
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => currentUser);

    if (throwError) {
      when(mockUserService.getFollowing(any))
          .thenThrow(Exception('Failed to load following'));
      when(mockUserService.getFollowers(any))
          .thenThrow(Exception('Failed to load followers'));
    } else {
      when(mockUserService.getFollowing(any))
          .thenAnswer((_) async => following ?? []);
      when(mockUserService.getFollowers(any))
          .thenAnswer((_) async => followers ?? []);
    }

    when(mockUserService.searchUsers(any))
        .thenAnswer((_) async => following ?? []);
    when(mockUserService.unfollowUser(any, any)).thenAnswer((_) async => true);
    when(mockUserService.removeFollower(any, any))
        .thenAnswer((_) async => true);
    when(mockNotificationsService.unreadCount).thenReturn(0);
  }

  group('FollowView Widget Tests', () {
    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      setupMockResponses();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no following',
        (WidgetTester tester) async {
      setupMockResponses();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You are not following anyone yet'), findsOneWidget);
    });

    testWidgets('shows following list when data is available',
        (WidgetTester tester) async {
      setupMockResponses(following: testFollowing);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('following_user'), findsOneWidget);
      expect(find.text('Following User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('shows followers list when data is available',
        (WidgetTester tester) async {
      setupMockResponses(followers: testFollowers);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap followers tab
      await tester.tap(find.text('Followers'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('follower_user'), findsOneWidget);
      expect(find.text('Follower User'), findsOneWidget);
    });

    testWidgets('handles unfollow user action', (WidgetTester tester) async {
      setupMockResponses(following: testFollowing);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Unfollow'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockUserService.unfollowUser(any, any)).called(1);
    });

    testWidgets('handles remove follower action', (WidgetTester tester) async {
      setupMockResponses(followers: testFollowers);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Followers'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockUserService.removeFollower(any, any)).called(1);
    });

    testWidgets('handles search functionality', (WidgetTester tester) async {
      setupMockResponses(following: testFollowing);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find and tap search field
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockUserService.searchUsers('test')).called(2);
    });

    testWidgets('shows error state when loading fails',
        (WidgetTester tester) async {
      setupMockResponses(throwError: true);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Error: Exception: Failed to load following'),
          findsOneWidget);
    });

    testWidgets('handles no search results', (WidgetTester tester) async {
      when(mockUserService.searchUsers('nonexistent'))
          .thenAnswer((_) async => []);
      setupMockResponses();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets('handles profile picture loading error',
        (WidgetTester tester) async {
      final usersWithInvalidImage = [
        MyUser(
          id: '4',
          username: 'invalid_image_user',
          name: 'Invalid Image User',
          email: 'invalid@test.com',
          favoriteGenres: [],
          following: [],
          followers: [],
          likedMovies: [],
          seenMovies: [],
          followedWatchlists: {},
          profilePicture: 'invalid_url',
        )
      ];

      setupMockResponses(following: usersWithInvalidImage);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.person), findsWidgets);
    });
  });
}
