import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([DocumentSnapshot])
import 'watchlist_test.mocks.dart';

void main() {
  group('WatchList', () {
    test('fromFirestore creates WatchList object correctly', () {
      final mockSnapshot = MockDocumentSnapshot();

      when(mockSnapshot.data()).thenReturn({
        'userID': 'user123',
        'name': 'My Watchlist',
        'isPrivate': true,
        'movies': [1, 2, 3],
        'followers': ['follower1', 'follower2'],
        'collaborators': ['collab1', 'collab2'],
        'createdAt': '2023-01-01',
        'updatedAt': '2023-01-02'
      });
      when(mockSnapshot.id).thenReturn('testId');

      final watchlist = WatchList.fromFirestore(mockSnapshot);

      expect(watchlist.id, 'testId');
      expect(watchlist.userID, 'user123');
      expect(watchlist.name, 'My Watchlist');
      expect(watchlist.isPrivate, true);
      expect(watchlist.movies, [1, 2, 3]);
      expect(watchlist.followers, ['follower1', 'follower2']);
      expect(watchlist.collaborators, ['collab1', 'collab2']);
      expect(watchlist.createdAt, '2023-01-01');
      expect(watchlist.updatedAt, '2023-01-02');
    });

    test('toMap converts WatchList object to Map correctly', () {
      final watchlist = WatchList(
        id: 'watchlist123',
        userID: 'user123',
        name: 'My Watchlist',
        isPrivate: true,
        movies: [1, 2, 3],
        followers: ['follower1', 'follower2'],
        collaborators: ['collab1', 'collab2'],
        createdAt: '2023-01-01',
        updatedAt: '2023-01-02',
      );

      final map = watchlist.toMap();

      expect(map['id'], 'watchlist123');
      expect(map['userID'], 'user123');
      expect(map['name'], 'My Watchlist');
      expect(map['isPrivate'], true);
      expect(map['movies'], [1, 2, 3]);
      expect(map['followers'], ['follower1', 'follower2']);
      expect(map['collaborators'], ['collab1', 'collab2']);
      expect(map['createdAt'], '2023-01-01');
      expect(map['updatedAt'], '2023-01-02');
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = WatchList(
        id: 'watchlist123',
        userID: 'user123',
        name: 'My Watchlist',
        isPrivate: true,
        movies: [1, 2, 3],
        followers: ['follower1', 'follower2'],
        collaborators: ['collab1', 'collab2'],
        createdAt: '2023-01-01',
        updatedAt: '2023-01-02',
      );

      final updated = original.copyWith(
        name: 'Updated Watchlist',
        isPrivate: false,
        movies: [4, 5, 6],
        updatedAt: '2023-01-03',
      );

      expect(updated.id, original.id);
      expect(updated.userID, original.userID);
      expect(updated.name, 'Updated Watchlist');
      expect(updated.isPrivate, false);
      expect(updated.movies, [4, 5, 6]);
      expect(updated.followers, original.followers);
      expect(updated.collaborators, original.collaborators);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, isNot(equals(original.updatedAt)));
    });
  });
}
