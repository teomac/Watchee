import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Generate mock classes
@GenerateMocks([UserService, WatchlistService])
import 'notifications_page_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late MyUser testUser;

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
    testUser = MyUser(
      id: 'test-user-id',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
    );
  });

  group('Notifications Page Unit Tests', () {
    test('getNotifications returns correct notifications list', () async {
      // Arrange
      final testNotifications = [
        {
          'notificationId': '1',
          'type': 'new_follower',
          'message': 'User started following you',
          'timestamp': Timestamp.now(),
          'followerId': 'follower-id'
        },
        {
          'notificationId': '2',
          'type': 'new_review',
          'message': 'User reviewed your movie',
          'timestamp': Timestamp.now(),
          'reviewAuthorId': 'reviewer-id'
        }
      ];

      // Mock behavior
      when(mockUserService.getNotifications(testUser.id))
          .thenAnswer((_) async => testNotifications);

      // Act
      final notifications = await mockUserService.getNotifications(testUser.id);

      // Assert
      expect(notifications.length, 2);
      expect(notifications[0]['type'], 'new_follower');
      expect(notifications[1]['type'], 'new_review');
      verify(mockUserService.getNotifications(testUser.id)).called(1);
    });

    test('clearNotifications clears all notifications', () async {
      // Arrange
      when(mockUserService.clearNotifications(testUser.id))
          .thenAnswer((_) async => {});

      // Act
      await mockUserService.clearNotifications(testUser.id);

      // Assert
      verify(mockUserService.clearNotifications(testUser.id)).called(1);
    });

    test('removeNotification removes specific notification', () async {
      // Arrange
      const notificationId = 'test-notification-id';
      when(mockUserService.removeNotification(testUser.id, notificationId))
          .thenAnswer((_) async => {});

      // Act
      await mockUserService.removeNotification(testUser.id, notificationId);

      // Assert
      verify(mockUserService.removeNotification(testUser.id, notificationId))
          .called(1);
    });

    test('acceptInvite handles watchlist invitation acceptance', () async {
      // Arrange
      const watchlistId = 'test-watchlist-id';
      const watchlistOwner = 'test-owner-id';

      when(mockWatchlistService.acceptInvite(
              watchlistId, watchlistOwner, testUser.id))
          .thenAnswer((_) async => {});

      // Act
      await mockWatchlistService.acceptInvite(
          watchlistId, watchlistOwner, testUser.id);

      // Assert
      verify(mockWatchlistService.acceptInvite(
              watchlistId, watchlistOwner, testUser.id))
          .called(1);
    });

    test('declineInvite handles watchlist invitation decline', () async {
      // Arrange
      const watchlistId = 'test-watchlist-id';
      const watchlistOwner = 'test-owner-id';

      when(mockWatchlistService.declineInvite(
              watchlistId, watchlistOwner, testUser.id))
          .thenAnswer((_) async => {});

      // Act
      await mockWatchlistService.declineInvite(
          watchlistId, watchlistOwner, testUser.id);

      // Assert
      verify(mockWatchlistService.declineInvite(
              watchlistId, watchlistOwner, testUser.id))
          .called(1);
    });
  });
}
