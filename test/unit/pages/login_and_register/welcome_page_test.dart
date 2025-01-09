import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../mocks/welcome_page_test.mocks.dart';

@GenerateMocks([
  UserService,
  ImagePicker,
  FirebaseAuth,
  User,
])
void main() {
  late MockUserService mockUserService;
  late MockImagePicker mockImagePicker;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockUserService = MockUserService();
    mockImagePicker = MockImagePicker();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeFirestore = FakeFirebaseFirestore();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
  });

  group('UserService Tests', () {
    test('isUsernameAvailable returns true for unique username', () async {
      when(mockUserService.isUsernameAvailable('newuser'))
          .thenAnswer((_) async => true);

      bool result = await mockUserService.isUsernameAvailable('newuser');
      expect(result, true);
      verify(mockUserService.isUsernameAvailable('newuser')).called(1);
    });

    test('isUsernameAvailable returns false for taken username', () async {
      when(mockUserService.isUsernameAvailable('existinguser'))
          .thenAnswer((_) async => false);

      bool result = await mockUserService.isUsernameAvailable('existinguser');
      expect(result, false);
      verify(mockUserService.isUsernameAvailable('existinguser')).called(1);
    });
  });

  group('Image Picker Tests', () {
    test('pickImage returns XFile when image is selected', () async {
      final mockXFile = XFile('test/path/image.jpg');
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);

      final result =
          await mockImagePicker.pickImage(source: ImageSource.gallery);
      expect(result?.path, mockXFile.path);
      verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
    });

    test('pickImage returns null when no image is selected', () async {
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => null);

      final result =
          await mockImagePicker.pickImage(source: ImageSource.gallery);
      expect(result, null);
      verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
    });
  });

  group('Firestore Tests', () {
    test('Successfully updates user document', () async {
      await fakeFirestore.collection('users').doc('test-uid').set({
        'name': '',
        'username': '',
        'profilePicture': null,
      });

      await fakeFirestore.collection('users').doc('test-uid').update({
        'name': 'Test User',
        'username': 'testuser',
      });

      final docSnapshot =
          await fakeFirestore.collection('users').doc('test-uid').get();
      expect(docSnapshot.get('name'), 'Test User');
      expect(docSnapshot.get('username'), 'testuser');
    });
  });

  group('User Model Tests', () {
    test('Successfully creates MyUser object', () {
      final user = MyUser(
        id: 'test-id',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
        profilePicture: null,
        favoriteGenres: [],
        following: [],
        followers: [],
        likedMovies: [],
        seenMovies: [],
        followedWatchlists: {},
      );

      expect(user.id, 'test-id');
      expect(user.username, 'testuser');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.profilePicture, null);
      expect(user.favoriteGenres, isEmpty);
    });
  });
}
