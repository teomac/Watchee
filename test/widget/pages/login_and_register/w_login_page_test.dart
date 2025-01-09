// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/login_and_register/login_page.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_login_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseMessaging>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<FCMService>(),
  MockSpec<CustomAuth>(),
  MockSpec<CustomGoogleAuth>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockFCMService mockFCMService;
  late MockCustomAuth mockCustomAuth;
  late MockCustomGoogleAuth mockCustomGoogleAuth;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockFCMService = MockFCMService();
    mockCustomAuth = MockCustomAuth();
    mockCustomGoogleAuth = MockCustomGoogleAuth();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createLoginPage() {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseMessaging>(create: (_) => mockFirebaseMessaging),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<FCMService>(create: (_) => mockFCMService),
        Provider<CustomAuth>(create: (_) => mockCustomAuth),
        Provider<CustomGoogleAuth>(create: (_) => mockCustomGoogleAuth),
      ],
      child: MaterialApp(
        home: const LoginPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  testWidgets('Login page should render all initial elements',
      (WidgetTester tester) async {
    // Set a sufficient viewport size to avoid overflow
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createLoginPage());

    // Verify app title and logo
    expect(find.text('Watchee'), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);

    // Verify input fields
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    // Verify buttons and texts
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets); // Verify RichText exists
    expect(find.text('Or continue with'), findsOneWidget);
    expect(find.text('Not a member? Register now'), findsOneWidget);
    expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);

    // Reset the window size after the test
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Should show error when fields are empty',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createLoginPage());

    // Tap sign in button without filling fields
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Verify error message
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });

  testWidgets('Should show error for invalid email format',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createLoginPage());

    // Enter invalid email and password
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('Should navigate to register page when register link is tapped',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createLoginPage());

    await tester.tap(find.text('Not a member? Register now'));
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets(
      'Should navigate to reset password page when forgot password is tapped',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createLoginPage());

    //retrieve forgot password richtext
    await tester.tap(find.byKey(const Key('forgot_password')));
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('Should attempt login with valid credentials',
      (WidgetTester tester) async {
    // Set up mocks
    when(mockCustomAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'Password123!',
    )).thenAnswer((_) async {
      // Small delay to simulate network request
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    });

    when(mockFirebaseMessaging.getToken())
        .thenAnswer((_) async => 'mock_token');

    when(mockFCMService.storeFCMToken(any)).thenAnswer((_) async => {});

    when(mockFCMService.storeFCMTokenToFirestore(any))
        .thenAnswer((_) async => {});

    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    // Build our app and trigger a frame.
    await tester.pumpWidget(createLoginPage());

    // Enter credentials
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'Password123!');

    // Tap the sign in button
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Wait for the login process to complete
    await tester.pump(const Duration(milliseconds: 200));

    // Verify the auth method was called
    verify(mockCustomAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'Password123!',
    )).called(1);

    // Verify FCM token operations were called
    verify(mockFCMService.storeFCMToken(any)).called(1);
    verify(mockFCMService.storeFCMTokenToFirestore(any)).called(1);
  });
  testWidgets('Should handle Google sign in', (WidgetTester tester) async {
    final mockUserCredential = MockUserCredential();
    when(mockCustomGoogleAuth.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createLoginPage());

    await tester.dragUntilVisible(
      find.byKey(const Key('google_sign_in_button')),
      find.byType(SingleChildScrollView),
      const Offset(0, 500),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('google_sign_in_button')));
    await tester.pump();

    verify(mockCustomGoogleAuth.signInWithGoogle()).called(1);
  });

  testWidgets('Should show error message on login failure',
      (WidgetTester tester) async {
    // Set up mock auth to throw an error
    when(mockCustomAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Simulate network delay
      throw 'Invalid email or password';
    });

    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createLoginPage());

    // Enter credentials
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password');

    // Tap sign in button
    await tester.tap(find.text('Sign In'));

    // Wait for the loading dialog to appear
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the error to be thrown and dialog to be dismissed
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Invalid email or password'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
}

// Mock classes needed for testing
class MockUserCredential extends Mock implements UserCredential {}
