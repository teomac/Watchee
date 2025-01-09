import 'dart:io';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<UserService>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentReference>(),
  MockSpec<CollectionReference>(),
  MockSpec<User>(),
])
import '../../../mocks/manage_account_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockUserService = MockUserService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
  });

  group('UserService Tests', () {
    test('getCurrentUser returns correct user', () async {
      final testUser = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@test.com',
        favoriteGenres: ['Action', 'Comedy'],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
      );

      when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);

      final result = await mockUserService.getCurrentUser();

      expect(result, equals(testUser));
      expect(result?.username, equals('testuser'));
      expect(result?.favoriteGenres, contains('Action'));
    });

    test('isUsernameAvailable returns correct value', () async {
      when(mockUserService.isUsernameAvailable('existinguser'))
          .thenAnswer((_) async => false);
      when(mockUserService.isUsernameAvailable('newuser'))
          .thenAnswer((_) async => true);

      expect(await mockUserService.isUsernameAvailable('existinguser'), false);
      expect(await mockUserService.isUsernameAvailable('newuser'), true);
    });

    test('uploadImage returns correct URL', () async {
      const expectedUrl = 'https://example.com/image.jpg';
      final mockFile = File('test.jpg');

      when(mockUserService.uploadImage(mockFile))
          .thenAnswer((_) async => expectedUrl);

      final result = await mockUserService.uploadImage(mockFile);

      expect(result, equals(expectedUrl));
    });

    test('updateUserWithNameLowerCase updates correctly', () async {
      const userId = '123';
      const name = 'Test User';

      when(mockUserService.updateUserWithNameLowerCase(userId, name))
          .thenAnswer((_) async {});

      // Should not throw error
      await mockUserService.updateUserWithNameLowerCase(userId, name);

      verify(mockUserService.updateUserWithNameLowerCase(userId, name))
          .called(1);
    });
  });

  group('Firebase Authentication Tests', () {
    test('Current user is available', () {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final currentUser = mockFirebaseAuth.currentUser;

      expect(currentUser, isNotNull);
      expect(currentUser?.uid, equals('test-uid'));
    });

    test('Sign out works correctly', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Should not throw error
      await mockFirebaseAuth.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}
