import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/login_and_register/welcome_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_welcome_page_test.mocks.dart';

// Generate mocks for all required classes
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  UserService,
  User,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockUsersCollectionReference,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
    as: #MockUserDocumentReference,
  ),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserService mockUserService;
  late MockUser mockUser;
  late MockUsersCollectionReference mockCollectionReference;
  late MockUserDocumentReference mockDocumentReference;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserService = MockUserService();
    mockUser = MockUser();
    mockCollectionReference = MockUsersCollectionReference();
    mockDocumentReference = MockUserDocumentReference();

    // Setup default mock behaviors
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>.value(value: mockAuth),
        Provider<FirebaseFirestore>.value(value: mockFirestore),
        Provider<UserService>.value(value: mockUserService),
      ],
      child: const MaterialApp(
        home: WelcomeScreen(),
      ),
    );
  }

  testWidgets('renders welcome screen with all required elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Username *'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('shows error message when fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Try to submit empty form
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });

  group('Username validation', () {
    testWidgets('shows error when username is too short',
        (WidgetTester tester) async {
      when(mockUserService.isUsernameAvailable(any))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter short username
      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), 'ab');
      await tester.pump();

      expect(find.text('Username must be at least 3 characters long'),
          findsOneWidget);
    });

    testWidgets('shows success when username is available',
        (WidgetTester tester) async {
      when(mockUserService.isUsernameAvailable(any))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), 'validuser');
      await tester.pump();

      expect(find.text('Username is available'), findsOneWidget);
    });

    testWidgets('shows error when username is not available',
        (WidgetTester tester) async {
      when(mockUserService.isUsernameAvailable(any))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), 'takenuser');
      await tester.pump();

      expect(find.text('Username is not available'), findsOneWidget);
    });
  });

  testWidgets('successful form submission updates user data',
      (WidgetTester tester) async {
    when(mockUserService.isUsernameAvailable(any))
        .thenAnswer((_) async => true);
    when(mockUserService.updateUserWithNameLowerCase(any, any))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    // Fill form with valid data
    await tester.enterText(
        find.widgetWithText(TextField, 'Name *'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextField, 'Username *'), 'testuser');
    await tester.pump();

    // Submit form
    await tester.tap(find.text('Next'));
    await tester.pump();

    // Verify Firestore update was called
    verify(mockFirestore.collection('users')).called(1);
    verify(mockDocumentReference.update(any)).called(1);
  });

  testWidgets('shows error message on Firestore update failure',
      (WidgetTester tester) async {
    when(mockUserService.isUsernameAvailable(any))
        .thenAnswer((_) async => true);
    when(mockDocumentReference.update(any))
        .thenThrow(Exception('Firestore error'));

    await tester.pumpWidget(createWidgetUnderTest());

    // Fill form with valid data
    await tester.enterText(
        find.widgetWithText(TextField, 'Name *'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextField, 'Username *'), 'testuser');
    await tester.pump();

    // Submit form
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('An error occurred'), findsOneWidget);
  });
}
