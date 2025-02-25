import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([DocumentSnapshot])
import '../../mocks/watchlist_test.mocks.dart';

void main() {
  const String movie1 = '1,,, Movie1,,, poster1.jpg,,, 2023-01-01';
  const String movie2 = '2,,, Movie2,,, poster2.jpg,,, 2023-01-02';
  const String movie3 = '3,,, Movie3,,, poster3.jpg,,, 2023-01-03';
  const String movie4 = '4,,, Movie4,,, poster4.jpg,,, 2023-01-04';
  const String movie5 = '5,,, Movie5,,, poster5.jpg,,, 2023-01-05';

  group('WatchList', () {
    test('fromFirestore creates WatchList object correctly', () {
      final mockSnapshot = MockDocumentSnapshot();

      when(mockSnapshot.data()).thenReturn({
        'userID': 'user123',
        'name': 'My Watchlist',
        'isPrivate': true,
        'movies': [movie1, movie2, movie3],
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
      expect(watchlist.movies, [movie1, movie2, movie3]);
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
        movies: [movie1, movie2, movie3],
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
      expect(map['movies'], [movie1, movie2, movie3]);
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
        movies: [movie1, movie2, movie3],
        followers: ['follower1', 'follower2'],
        collaborators: ['collab1', 'collab2'],
        createdAt: '2023-01-01',
        updatedAt: '2023-01-02',
      );

      final updated = original.copyWith(
        name: 'Updated Watchlist',
        isPrivate: false,
        movies: [movie4, movie5],
        updatedAt: '2023-01-03',
      );

      expect(updated.id, original.id);
      expect(updated.userID, original.userID);
      expect(updated.name, 'Updated Watchlist');
      expect(updated.isPrivate, false);
      expect(updated.movies, [movie4, movie5]);
      expect(updated.followers, original.followers);
      expect(updated.collaborators, original.collaborators);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, isNot(equals(original.updatedAt)));
    });
  });
}
