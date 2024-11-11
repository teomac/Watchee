import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';

void main() {
  final logger = Logger();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test account credentials - use a dedicated test account
  const String testEmail = 'piergrulli@gmail.com';
  const String testPassword = 'Ciao123\$';

  setUpAll(() async {
    // Initialize Firebase before running tests
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() async {
    // Sign out before each test to ensure a clean state
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    // Clean up after each test
    await FirebaseAuth.instance.signOut();
  });

  // Helper function to wrap the app with necessary providers
  Widget createTestableApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeMode(),
      child: MyApp(initialUri: null),
    );
  }

  testWidgets('Successful login test', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(createTestableApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find and fill text fields
    final emailField = find.widgetWithText(TextField, 'Email');
    final passwordField = find.widgetWithText(TextField, 'Password');

    await tester.enterText(emailField, testEmail);
    await tester.enterText(passwordField, testPassword);

    // Find and tap login button
    final loginButton = find.text('Sign In');
    await tester.tap(loginButton);

    // Wait for authentication and navigation
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Here we add error handling for widget building
    try {
      // Verify we're on the home page
      expect(find.text('Home'), findsOneWidget);

      // Additional verifications you might want to add
      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser?.email, equals(testEmail));
    } catch (e) {
      // If we get an error, log the current widget tree
      debugDumpApp();
      rethrow;
    }
  });

  group('Login Tests', () {
    testWidgets('Failed login - incorrect credentials',
        (WidgetTester tester) async {
      // Build app
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and fill text fields with incorrect credentials
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');

      await tester.enterText(emailField, 'invalidemail');
      await tester.enterText(passwordField, 'password123');

      // Find and tap login button
      final loginButton = find.text('Sign In');
      await tester.tap(loginButton);

      // Wait for authentication attempt
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify error state
      expect(
          find.text(
              'The email address is badly formatted.'), // This is the error message we expect
          findsOneWidget);

      // Additional verification
      expect(FirebaseAuth.instance.currentUser, isNull);
    });

    testWidgets('Failed login - empty fields', (WidgetTester tester) async {
      // Build app
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap login button without entering credentials
      final loginButton = find.text('Sign In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('Please fill in all fields'), findsOneWidget);

      // Additional verification
      expect(FirebaseAuth.instance.currentUser, isNull);
    });

    testWidgets('Successful Google Sign In', (WidgetTester tester) async {
      // Build app
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Find and tap the Google sign in button
      final googleSignInButton = find.byKey(const Key('google_sign_in_button'));
      expect(googleSignInButton, findsOneWidget);
      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();
      // Wait for Google Sign In process and navigation
      await Future.delayed(const Duration(seconds: 5));

      try {
        // Pump until navigation completes
        await tester.pumpAndSettle();

        // Wait for Firestore operations
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Verify we're on the home page
        expect(find.text('Home'), findsOneWidget);
        expect(FirebaseAuth.instance.currentUser, isNotNull);
      } catch (e) {
        logger.d('Current widget tree:');
        debugDumpApp();
        rethrow;
      }
    });
  });
}
