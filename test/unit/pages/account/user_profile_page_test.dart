import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<UserService>(),
  MockSpec<WatchlistService>(),
])
import '../../../mocks/user_profile_page_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
  });

  group('UserService Interactions', () {
    final testUser = MyUser(
      id: 'testId',
      username: 'testUser',
      name: 'Test User',
      email: 'test@test.com',
      following: [],
      followers: [],
      favoriteGenres: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    test('getCurrentUser returns correct user', () async {
      when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);

      final result = await mockUserService.getCurrentUser();
      expect(result, equals(testUser));
      verify(mockUserService.getCurrentUser()).called(1);
    });

    test('isFollowing returns correct status', () async {
      when(mockUserService.isFollowing('currentUserId', 'targetUserId'))
          .thenAnswer((_) async => true);

      final result =
          await mockUserService.isFollowing('currentUserId', 'targetUserId');
      expect(result, isTrue);
      verify(mockUserService.isFollowing('currentUserId', 'targetUserId'))
          .called(1);
    });

    test('getFollowers returns correct list', () async {
      final followers = [testUser];
      when(mockUserService.getFollowers('testId'))
          .thenAnswer((_) async => followers);

      final result = await mockUserService.getFollowers('testId');
      expect(result, equals(followers));
      verify(mockUserService.getFollowers('testId')).called(1);
    });

    test('getReviewsByUser returns correct reviews', () async {
      final reviews = [
        MovieReview(
          id: 'reviewId',
          userId: 'testId',
          movieId: 123,
          text: 'Great movie!',
          rating: 5,
          timestamp: Timestamp.now(),
          title: 'Test Movie',
          username: 'testUser',
        ),
      ];

      when(mockUserService.getReviewsByUser('testId'))
          .thenAnswer((_) async => reviews);

      final result = await mockUserService.getReviewsByUser('testId');
      expect(result, equals(reviews));
      verify(mockUserService.getReviewsByUser('testId')).called(1);
    });
  });

  group('WatchlistService Interactions', () {
    final testWatchlist = WatchList(
      id: 'watchlistId',
      userID: 'testId',
      name: 'Test Watchlist',
      isPrivate: false,
      movies: [],
      followers: [],
      collaborators: [],
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );

    test('getPublicWatchLists returns correct watchlists', () async {
      final watchlists = [testWatchlist];
      when(mockWatchlistService.getPublicWatchLists('testId'))
          .thenAnswer((_) async => watchlists);

      final result = await mockWatchlistService.getPublicWatchLists('testId');
      expect(result, equals(watchlists));
      verify(mockWatchlistService.getPublicWatchLists('testId')).called(1);
    });

    test('getPublicWatchLists handles empty list', () async {
      when(mockWatchlistService.getPublicWatchLists('testId'))
          .thenAnswer((_) async => []);

      final result = await mockWatchlistService.getPublicWatchLists('testId');
      expect(result, isEmpty);
      verify(mockWatchlistService.getPublicWatchLists('testId')).called(1);
    });
  });

  group('Error Handling', () {
    test('getCurrentUser handles errors gracefully', () async {
      when(mockUserService.getCurrentUser())
          .thenThrow(Exception('Network error'));

      expect(() => mockUserService.getCurrentUser(), throwsException);
      verify(mockUserService.getCurrentUser()).called(1);
    });

    test('getPublicWatchLists handles errors gracefully', () async {
      when(mockWatchlistService.getPublicWatchLists('testId'))
          .thenThrow(Exception('Database error'));

      expect(
        () => mockWatchlistService.getPublicWatchLists('testId'),
        throwsException,
      );
      verify(mockWatchlistService.getPublicWatchLists('testId')).called(1);
    });
  });
}
