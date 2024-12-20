import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  final logger = Logger();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test account credentials - use a dedicated test account
  const String testEmail = 'fritziano@gmail.com';
  const String testPassword = 'Ciao123\$';

  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late GoogleSignIn googleSignIn;
  late UserService userService;
  late WatchlistService watchlistService;
  late CustomAuth customAuth;
  late CustomGoogleAuth customGoogleAuth;
  late FirebaseMessaging messaging;
  late FCMService fcmService;
  late NotificationsService notificationsService;
  late TmdbApiService tmdbApiService;

  setUpAll(() async {
    // Initialize Firebase before running tests
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() async {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    googleSignIn = GoogleSignIn();
    userService = UserService(auth: auth, firestore: firestore);
    messaging = FirebaseMessaging.instance;
    watchlistService =
        WatchlistService(firestore: firestore, userService: userService);
    customAuth = CustomAuth(firebaseAuth: auth, googleSignIn: googleSignIn);
    customGoogleAuth = CustomGoogleAuth(
      auth: auth,
      firestore: firestore,
      googleSignIn: googleSignIn,
      userService: userService,
    );
    fcmService =
        FCMService(messaging: messaging, firestore: firestore, auth: auth);
    notificationsService = NotificationsService();
    tmdbApiService = TmdbApiService();
    await auth.signOut();
  });

  // Helper function to wrap the app with necessary providers
  Widget createTestableApp() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThemeProvider()..loadThemeMode()),
          Provider<FirebaseAuth>.value(value: auth),
          Provider<FirebaseFirestore>.value(value: firestore),
          Provider<GoogleSignIn>.value(value: googleSignIn),
          Provider<FirebaseMessaging>.value(value: messaging),
          Provider<UserService>.value(value: userService),
          Provider<CustomAuth>.value(value: customAuth),
          Provider<CustomGoogleAuth>.value(value: customGoogleAuth),
          Provider<WatchlistService>.value(value: watchlistService),
          Provider<FCMService>.value(value: fcmService),
          Provider<NotificationsService>.value(value: notificationsService),
          Provider<TmdbApiService>.value(value: tmdbApiService),
        ],
        child: const MyApp(initialUri: null),
      ),
    );
  }

  Future<void> performLogin(
      WidgetTester tester, String email, String password) async {
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), password);
    await tester.pump();
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  group('Login UI Tests', () {
    testWidgets('Basic UI elements are displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));

      // Verify presence of all major UI elements
      expect(find.text('Watchee'), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Or continue with'), findsOneWidget);
      expect(find.text('Not a member? Register now'), findsOneWidget);
    });
  });

  group('Successful Login Functionality Tests', () {
    testWidgets('Successful login flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await performLogin(tester, testEmail, testPassword);

      await Future.delayed(const Duration(seconds: 2));
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }

      expect(find.text('Home'), findsOneWidget);
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser?.email, equals(testEmail));
    });
  });

  group('Reset password Functionality Tests', () {
    testWidgets('Failed login - invalid credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await performLogin(tester, 'wrong@email.com', 'wrongpassword');
      expect(find.text('Invalid email or password'), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
    });

    testWidgets('Failed login - empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields'), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
    });
  });

  group('Failed Login Functionality Tests', () {
    testWidgets('Forgot password navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Tap forgot password link
      final richTextFinder = find.byWidgetPredicate((widget) =>
          widget is RichText &&
          widget.text.toPlainText() == 'Forgot password?');

      expect(richTextFinder, findsOneWidget);
      await tester.tap(richTextFinder);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));

      // Verify we're on the reset password page
      expect(find.text('Reset Password'), findsWidgets);

      // Test empty submission
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'invalid');
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test valid email
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      expect(find.text('Password reset email sent. Check your inbox.'),
          findsOneWidget);
    });

    testWidgets('Register navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Tap register link
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Verify we're on the register page
      expect(find.text('Register'), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
    });
  });

  group('Google Sign In Tests', () {
    testWidgets('Successful Google Sign In', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      final googleSignInButton = find.byKey(const Key('google_sign_in_button'));
      expect(googleSignInButton, findsOneWidget);
      await tester.tap(googleSignInButton);
      await Future.delayed(const Duration(seconds: 5));

      try {
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(FirebaseAuth.instance.currentUser, isNotNull);
      } catch (e) {
        logger.d('Current widget tree:');
        debugDumpApp();
        rethrow;
      }
    });

    testWidgets('Google Sign In cancellation handling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Simulate cancelled Google Sign In
      final googleSignInButton = find.byKey(const Key('google_sign_in_button'));
      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();

      // Verify we're still on the login page
      expect(find.text('Sign In'), findsOneWidget);
      expect(FirebaseAuth.instance.currentUser, isNull);
    });
  });
}
