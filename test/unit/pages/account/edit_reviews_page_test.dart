// edit_reviews_unit_test.dart
import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateNiceMocks([MockSpec<UserService>()])
import 'edit_reviews_page_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MyUser testUser;
  late List<MovieReview> testReviews;

  setUp(() {
    mockUserService = MockUserService();
    testUser = MyUser(
      id: 'test-user-id',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
    );

    testReviews = [
      MovieReview(
        id: 'review1',
        userId: testUser.id,
        movieId: 1,
        text: 'Great movie!',
        rating: 5,
        timestamp: Timestamp.now(),
        title: 'Test Movie 1',
        username: testUser.username,
      ),
      MovieReview(
        id: 'review2',
        userId: testUser.id,
        movieId: 2,
        text: 'Not so great.',
        rating: 2,
        timestamp: Timestamp.now(),
        title: 'Test Movie 2',
        username: testUser.username,
      ),
    ];
  });

  group('UserService Review Operations', () {
    test('getCurrentUser returns correct user', () async {
      when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);

      final result = await mockUserService.getCurrentUser();
      expect(result, equals(testUser));
      verify(mockUserService.getCurrentUser()).called(1);
    });

    test('deleteReviews deletes selected reviews successfully', () async {
      when(mockUserService.deleteReviews(any, any)).thenAnswer((_) async => {});

      await mockUserService.deleteReviews(testUser.id, testReviews);
      verify(mockUserService.deleteReviews(testUser.id, testReviews)).called(1);
    });

    test('deleteReviews handles empty review list', () async {
      when(mockUserService.deleteReviews(any, any)).thenAnswer((_) async => {});

      await mockUserService.deleteReviews(testUser.id, []);
      verify(mockUserService.deleteReviews(testUser.id, [])).called(1);
    });

    test('deleteReviews throws exception for invalid user', () async {
      when(mockUserService.deleteReviews(any, any))
          .thenThrow(Exception('User not found'));

      expect(() => mockUserService.deleteReviews('invalid-id', testReviews),
          throwsException);
    });
  });

  group('MovieReview Model Tests', () {
    test('MovieReview creates from valid data', () {
      final timestamp = Timestamp.now();
      final review = MovieReview(
        id: 'test-id',
        userId: 'user-id',
        movieId: 1,
        text: 'Test review',
        rating: 4,
        timestamp: timestamp,
        title: 'Test Movie',
        username: 'testuser',
      );

      expect(review.id, equals('test-id'));
      expect(review.userId, equals('user-id'));
      expect(review.movieId, equals(1));
      expect(review.text, equals('Test review'));
      expect(review.rating, equals(4));
      expect(review.timestamp, equals(timestamp));
      expect(review.title, equals('Test Movie'));
      expect(review.username, equals('testuser'));
    });

    test('MovieReview converts to map correctly', () {
      final timestamp = Timestamp.now();
      final review = MovieReview(
        id: 'test-id',
        userId: 'user-id',
        movieId: 1,
        text: 'Test review',
        rating: 4,
        timestamp: timestamp,
        title: 'Test Movie',
        username: 'testuser',
      );

      final map = review.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['userId'], equals('user-id'));
      expect(map['movieId'], equals(1));
      expect(map['text'], equals('Test review'));
      expect(map['rating'], equals(4));
      expect(map['timestamp'], equals(timestamp));
      expect(map['title'], equals('Test Movie'));
      expect(map['username'], equals('testuser'));
    });

    test('MovieReview handles invalid rating values', () {
      expect(
        () => MovieReview(
          id: 'test-id',
          userId: 'user-id',
          movieId: 1,
          text: 'Test review',
          rating: 6, // Invalid rating > 5
          timestamp: Timestamp.now(),
          title: 'Test Movie',
          username: 'testuser',
        ),
        throwsAssertionError,
      );

      expect(
        () => MovieReview(
          id: 'test-id',
          userId: 'user-id',
          movieId: 1,
          text: 'Test review',
          rating: -1, // Invalid rating < 0
          timestamp: Timestamp.now(),
          title: 'Test Movie',
          username: 'testuser',
        ),
        throwsAssertionError,
      );
    });
  });
}
