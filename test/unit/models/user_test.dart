import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/user.dart';

void main() {
  const String movie1 = '1,,, Movie1,,, poster1.jpg,,, 2023-01-01';
  const String movie2 = '2,,, Movie2,,, poster2.jpg,,, 2023-01-02';
  const String movie3 = '3,,, Movie3,,, poster3.jpg,,, 2023-01-03';
  const String movie4 = '4,,, Movie4,,, poster4.jpg,,, 2023-01-04';
  const String movie5 = '5,,, Movie5,,, poster5.jpg,,, 2023-01-05';
  const String movie6 = '6,,, Movie6,,, poster6.jpg,,, 2023-01-06';
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
        'likedMovies': [movie1, movie2, movie3],
        'seenMovies': [movie4, movie5, movie6],
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
      expect(user.likedMovies, [movie1, movie2, movie3]);
      expect(user.seenMovies, [movie4, movie5, movie6]);
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
        likedMovies: [movie1, movie2, movie3],
        seenMovies: [movie4, movie5, movie6],
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
      expect(map['likedMovies'], [movie1, movie2, movie3]);
      expect(map['seenMovies'], [movie4, movie5, movie6]);
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

  test('fromFirestore should handle empty map values', () {
    final map = {
      'id': '123',
      'username': '',
      'name': '',
      'email': '',
      'favoriteGenres': [],
      'following': [],
      'followers': [],
      'likedMovies': [],
      'seenMovies': [],
      'followedWatchlists': {},
      'pendingInvites': {},
      'collabWatchlists': {},
    };

    final user = MyUser.fromFirestore(map);
    expect(user.username, '');
    expect(user.name, '');
    expect(user.email, '');
    expect(user.favoriteGenres, isEmpty);
    expect(user.following, isEmpty);
    expect(user.followers, isEmpty);
    expect(user.likedMovies, isEmpty);
    expect(user.seenMovies, isEmpty);
    expect(user.followedWatchlists, isEmpty);
    expect(user.pendingInvites, isEmpty);
    expect(user.collabWatchlists, isEmpty);
  });

  test('equality operator should handle different list and map contents', () {
    final user1 = MyUser(
      id: '123',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      favoriteGenres: ['Action', 'Comedy'],
      following: ['456', '789'],
    );

    final user2 = MyUser(
      id: '123',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      favoriteGenres: ['Comedy', 'Action'], // Same elements, different order
      following: ['789', '456'], // Same elements, different order
    );

    final user3 = MyUser(
      id: '123',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      favoriteGenres: ['Action'], // Different content
      following: ['456'], // Different content
    );

    expect(user1 == user2, false); // Different order should make them unequal
    expect(user1 == user3, false); // Different content should make them unequal
  });

  test('should handle deeply nested map conversions', () {
    final complexMap = {
      'id': '123',
      'username': 'testuser',
      'name': 'Test User',
      'email': 'test@example.com',
      'followedWatchlists': {
        'user1': ['list1', 'list2'],
        'user2': ['list3', 'list4'],
      },
      'pendingInvites': {
        'user3': ['list5', 'list6'],
        'user4': ['list7', 'list8'],
      },
    };

    final user = MyUser.fromFirestore(complexMap);
    final convertedMap = user.toMap();

    expect(convertedMap['followedWatchlists'], {
      'user1': ['list1', 'list2'],
      'user2': ['list3', 'list4'],
    });
    expect(convertedMap['pendingInvites'], {
      'user3': ['list5', 'list6'],
      'user4': ['list7', 'list8'],
    });
  });

  test('should handle partial map updates in copyWith', () {
    final originalUser = MyUser(
      id: '123',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      followedWatchlists: {
        'user1': ['list1', 'list2'],
      },
    );

    final updatedUser = originalUser.copyWith(
      followedWatchlists: {
        'user1': ['list1', 'list2'],
        'user2': ['list3'],
      },
    );

    expect(updatedUser.followedWatchlists, {
      'user1': ['list1', 'list2'],
      'user2': ['list3'],
    });
    expect(updatedUser.id, originalUser.id);
    expect(updatedUser.username, originalUser.username);
  });
}
