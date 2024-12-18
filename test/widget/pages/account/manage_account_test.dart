import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/account/manage_account.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_account_test.mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([
  UserService,
  FirebaseAuth,
  FirebaseFirestore,
  DocumentReference,
  CollectionReference
])
void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MyUser testUser;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;

  setUp(() {
    mockUserService = MockUserService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();

    when(mockFirebaseFirestore.collection('users'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

    testUser = MyUser(
      id: '1',
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

    // Setup mock behaviors
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
    when(mockUserService.isUsernameAvailable(any))
        .thenAnswer((_) async => true);
    when(mockFirebaseAuth.currentUser).thenReturn(MockUser(uid: '1'));
    when(mockUserService.updateUser(any)).thenAnswer((_) async => {});
    when(mockUserService.updateUserWithNameLowerCase(any, any))
        .thenAnswer((_) async => {});
    when(mockUserService.updateUsernameInReviews(any, any))
        .thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserService>(create: (_) => mockUserService),
          Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
          Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        ],
        child: const ManageAccountPage(),
      ),
    );
  }

  testWidgets('ManageAccountPage displays user information correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Verify basic information is displayed
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('test@test.com'), findsOneWidget);

    // Verify user input fields
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    bool foundUsername = false;
    bool foundName = false;
    for (var field in textFields) {
      if (field.controller?.text == 'testuser') foundUsername = true;
      if (field.controller?.text == 'Test User') foundName = true;
    }
    expect(foundUsername, true);
    expect(foundName, true);

    // Verify profile picture
    final circleAvatars =
        tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));
    bool foundMainAvatar = false;
    for (var avatar in circleAvatars) {
      if (avatar.radius == 60) {
        // Main profile avatar has radius 60
        foundMainAvatar = true;
        expect(avatar.backgroundImage, isNull);
        break;
      }
    }
    expect(foundMainAvatar, true);

    // Verify UI elements
    expect(find.text('Favorite Genres'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Verify camera icon button is present
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Genre chips are displayed and can be interacted with',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Find the Wrap widget containing the FilterChips
    final wrapWidget = find.byType(Wrap);
    expect(wrapWidget, findsOneWidget);

    // Find and verify FilterChips
    final filterChips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    expect(filterChips.length, greaterThan(0));

    // Find and tap an unselected genre
    bool foundUnselectedChip = false;
    for (var chip in filterChips) {
      if (!chip.selected) {
        await tester.tap(find.byWidget(chip as Widget));
        await tester.pumpAndSettle();
        foundUnselectedChip = true;
        break;
      }
    }
    expect(foundUnselectedChip, true);
  });

  testWidgets('Username field validation works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Find username TextField
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    TextField? usernameField;
    for (var field in textFields) {
      if (field.controller?.text == 'testuser') {
        usernameField = field;
        break;
      }
    }
    expect(usernameField, isNotNull);

    // Clear username field
    await tester.enterText(find.byWidget(usernameField! as Widget), '');
    await tester.dragUntilVisible(find.text('Save Changes'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify error message for empty field
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpAndSettle();
    while (find.byType(SnackBar).evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
    }

    // Enter short username
    await tester.enterText(find.byWidget(usernameField as Widget), 'te');
    await tester.dragUntilVisible(find.text('Save Changes'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify error message for short username
    expect(find.text('Username must be at least 3 characters long'),
        findsOneWidget);
  });

  testWidgets('Name field validation works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Find name TextField
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    TextField? nameField;
    for (var field in textFields) {
      if (field.controller?.text == 'Test User') {
        nameField = field;
        break;
      }
    }
    expect(nameField, isNotNull);

    // Clear name field
    await tester.enterText(find.byWidget(nameField! as Widget), '');
    await tester.dragUntilVisible(find.text('Save Changes'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Save changes with valid data works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Find username and name TextFields
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    TextField? usernameField;
    TextField? nameField;
    for (var field in textFields) {
      if (field.controller?.text == 'testuser') {
        usernameField = field;
      } else if (field.controller?.text == 'Test User') {
        nameField = field;
      }
    }
    expect(usernameField, isNotNull);
    expect(nameField, isNotNull);

    // Enter valid data
    await tester.enterText(
        find.byWidget(usernameField! as Widget), 'newusername');
    await tester.enterText(find.byWidget(nameField! as Widget), 'New Name');
    await tester.dragUntilVisible(find.text('Save Changes'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    // Save changes
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Profile updated successfully'), findsOneWidget);

    // Verify the service methods were called
    verify(mockUserService.updateUsernameInReviews(any, any)).called(1);
    verify(mockUserService.updateUserWithNameLowerCase(any, any)).called(1);
  });

  testWidgets('Username availability check works', (WidgetTester tester) async {
    when(mockUserService.isUsernameAvailable('takenname'))
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Find username TextField
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    TextField? usernameField;
    for (var field in textFields) {
      if (field.controller?.text == 'testuser') {
        usernameField = field;
        break;
      }
    }
    expect(usernameField, isNotNull);

    // Enter taken username
    await tester.enterText(
        find.byWidget(usernameField! as Widget), 'takenname');
    await tester.dragUntilVisible(find.text('Save Changes'),
        find.byType(SingleChildScrollView), const Offset(0, 500));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Selected username is not available'), findsOneWidget);
  });
}

// Mock class for User
class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser({required this.uid});
}
