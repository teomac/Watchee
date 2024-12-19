// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/login_and_register/register_page.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'register_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseMessaging>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<FCMService>(),
  MockSpec<NavigatorObserver>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
  MockSpec<DocumentReference>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockFCMService mockFCMService;
  late MockNavigatorObserver mockNavigatorObserver;
  late VoidCallback mockShowLoginPage;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockCollectionReference mockCollectionReference;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockFCMService = MockFCMService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockDocumentReference = MockDocumentReference();
    mockCollectionReference = MockCollectionReference();
    mockShowLoginPage = () {};

    // Set up collection reference mock
    when(mockFirebaseFirestore.collection('users'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
  });

  Widget createRegisterPage() {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseMessaging>(create: (_) => mockFirebaseMessaging),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<FCMService>(create: (_) => mockFCMService),
      ],
      child: MaterialApp(
        home: RegisterPage(showLoginPage: mockShowLoginPage),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  testWidgets('Register page should render all initial elements',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    // Verify app title and logo
    expect(find.text('Watchee'), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);

    // Verify input fields
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Confirm password'), findsOneWidget);

    // Verify buttons and texts
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Already have an account? Login now'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Should show error when fields are empty',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    // Tap register button without filling fields
    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });

  testWidgets('Should show error for invalid email format',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'), 'Password123!');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('Should show error for password mismatch',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'Password123!');
    await tester.enterText(find.widgetWithText(TextField, 'Confirm password'),
        'DifferentPass123!');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Should show error for weak password',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'weak');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'), 'weak');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(
        find.text(
            'Password must have: at least 8 characters, including 1 uppercase, 1 number, and 1 special character.'),
        findsOneWidget);
  });

  testWidgets('Should attempt registration with valid credentials',
      (WidgetTester tester) async {
    final mockUserCredential = MockUserCredential();
    final mockUser = MockUser();
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');

    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'Password123!',
    )).thenAnswer((_) async => mockUserCredential);

    when(mockFirebaseMessaging.getToken())
        .thenAnswer((_) async => 'mock-token');

    // Mock document set operation
    when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'), 'Password123!');

    await tester.tap(find.text('Register'));
    await tester.pump();

    verify(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'Password123!',
    )).called(1);

    verify(mockDocumentReference.set(any)).called(1);
  });

  testWidgets('Should toggle password visibility', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    // Initially passwords should be obscured
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);

    // Toggle password visibility
    await tester.tap(find.byKey(const Key('visibility_toggle_Password')));
    await tester.pump();
  });

  testWidgets('Should navigate to login page when login link is tapped',
      (WidgetTester tester) async {
    bool loginPageCalled = false;
    mockShowLoginPage = () {
      loginPageCalled = true;
    };

    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.tap(find.text('Already have an account? Login now'));
    await tester.pump();

    expect(loginPageCalled, true);
  });

  testWidgets('Should show error on registration failure',
      (WidgetTester tester) async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createRegisterPage());

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'), 'Password123!');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('The account already exists for that email.'),
        findsOneWidget);
  });
}
