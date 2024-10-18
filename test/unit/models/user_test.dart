import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/user.dart';

void main() {
  group('MyUser', () {
    test('should create a MyUser instance from a complete map', () {
      final map = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'nameLowerCase': ['test', 'user'],
        'profilePicture': 'https://example.com/pic.jpg',
        'favoriteGenres': ['Action', 'Comedy'],
        'following': ['456', '789'],
        'followers': ['321', '654'],
        'likedMovies': [1, 2, 3],
        'seenMovies': [4, 5, 6],
        'followedWatchlists': {
          'user1': ['list1', 'list2']
        },
        'pendingInvites': {
          'user2': ['list3']
        },
        'collabWatchlists': {
          'user3': ['list4']
        },
      };

      final user = MyUser.fromFirestore(map);

      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.nameLowerCase, ['test', 'user']);
      expect(user.profilePicture, 'https://example.com/pic.jpg');
      expect(user.favoriteGenres, ['Action', 'Comedy']);
      expect(user.following, ['456', '789']);
      expect(user.followers, ['321', '654']);
      expect(user.likedMovies, [1, 2, 3]);
      expect(user.seenMovies, [4, 5, 6]);
      expect(user.followedWatchlists, {
        'user1': ['list1', 'list2']
      });
      expect(user.pendingInvites, {
        'user2': ['list3']
      });
      expect(user.collabWatchlists, {
        'user3': ['list4']
      });
    });

    test('should handle missing fields gracefully', () {
      final map = {
        'id': '123',
        'username': 'testuser',
        'email': 'test@example.com',
      };

      final user = MyUser.fromFirestore(map);

      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.name, '');
      expect(user.email, 'test@example.com');
      expect(user.nameLowerCase, isEmpty);
      expect(user.profilePicture, isNull);
      expect(user.favoriteGenres, isEmpty);
      expect(user.following, isEmpty);
      expect(user.followers, isEmpty);
      expect(user.likedMovies, isEmpty);
      expect(user.seenMovies, isEmpty);
      expect(user.followedWatchlists, isEmpty);
      expect(user.pendingInvites, isEmpty);
      expect(user.collabWatchlists, isEmpty);
    });

    test('should convert MyUser instance to a map', () {
      final user = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
        nameLowerCase: ['test', 'user'],
        profilePicture: 'https://example.com/pic.jpg',
        favoriteGenres: ['Action', 'Comedy'],
        following: ['456', '789'],
        followers: ['321', '654'],
        likedMovies: [1, 2, 3],
        seenMovies: [4, 5, 6],
        followedWatchlists: {
          'user1': ['list1', 'list2']
        },
        pendingInvites: {
          'user2': ['list3']
        },
        collabWatchlists: {
          'user3': ['list4']
        },
      );

      final map = user.toMap();

      expect(map['id'], '123');
      expect(map['username'], 'testuser');
      expect(map['name'], 'Test User');
      expect(map['email'], 'test@example.com');
      expect(map['nameLowerCase'], ['test', 'user']);
      expect(map['profilePicture'], 'https://example.com/pic.jpg');
      expect(map['favoriteGenres'], ['Action', 'Comedy']);
      expect(map['following'], ['456', '789']);
      expect(map['followers'], ['321', '654']);
      expect(map['likedMovies'], [1, 2, 3]);
      expect(map['seenMovies'], [4, 5, 6]);
      expect(map['followedWatchlists'], {
        'user1': ['list1', 'list2']
      });
      expect(map['pendingInvites'], {
        'user2': ['list3']
      });
      expect(map['collabWatchlists'], {
        'user3': ['list4']
      });
    });

    test('equality operator should work correctly', () {
      final user1 = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
      );

      final user2 = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
      );

      final user3 = MyUser(
        id: '456',
        username: 'otheruser',
        name: 'Other User',
        email: 'other@example.com',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('hashCode should be consistent', () {
      final user1 = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
      );

      final user2 = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
      );

      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('toString should return a string representation of the user', () {
      final user = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
      );

      final stringRepresentation = user.toString();

      expect(stringRepresentation, contains('MyUser'));
      expect(stringRepresentation, contains('id: 123'));
      expect(stringRepresentation, contains('username: testuser'));
      expect(stringRepresentation, contains('name: Test User'));
      expect(stringRepresentation, contains('email: test@example.com'));
    });

    test('should handle null values in lists and maps', () {
      final map = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'favoriteGenres': null,
        'following': null,
        'followers': null,
        'likedMovies': null,
        'seenMovies': null,
        'followedWatchlists': null,
        'pendingInvites': null,
        'collabWatchlists': null,
      };

      final user = MyUser.fromFirestore(map);

      expect(user.favoriteGenres, isEmpty);
      expect(user.following, isEmpty);
      expect(user.followers, isEmpty);
      expect(user.likedMovies, isEmpty);
      expect(user.seenMovies, isEmpty);
      expect(user.followedWatchlists, isEmpty);
      expect(user.pendingInvites, isEmpty);
      expect(user.collabWatchlists, isEmpty);
    });
  });
}
