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
      child: const MyApp(initialUri: null),
    );
  }

  group('Login UI Tests', () {
    testWidgets('Basic UI elements are displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Verify presence of all major UI elements
      expect(find.text('Watchee'), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Or continue with'), findsOneWidget);
      expect(find.text('Not a member? Register now'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Find password field and verify it's initially obscured
      final passwordField = find.widgetWithText(TextField, 'Password');
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

      // Toggle visibility and verify it changes
      final visibilityIcon = find.byIcon(Icons.visibility_off).first;
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
    });
  });

  group('Login Functionality Tests', () {
    testWidgets('Successful login test', (WidgetTester tester) async {
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

      try {
        // Verify we're on the home page
        expect(find.text('Home'), findsOneWidget);
        expect(FirebaseAuth.instance.currentUser, isNotNull);
        expect(FirebaseAuth.instance.currentUser?.email, equals(testEmail));
      } catch (e) {
        debugDumpApp();
        rethrow;
      }
    });

    testWidgets('Failed login - incorrect credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test with invalid email format
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'invalidemail');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'wrongpassword');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(
          find.text('The email address is badly formatted.'), findsOneWidget);

      // Test with correct email format but wrong credentials
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@test.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'wrongpassword');
      await tester.tap(find.text('Sign In'));
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('No user found'), findsOneWidget);
    });

    testWidgets('Failed login - empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test with both fields empty
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields'), findsOneWidget);

      // Test with only email
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@test.com');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields'), findsOneWidget);

      // Test with only password
      await tester.enterText(find.widgetWithText(TextField, 'Email'), '');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('Forgot password navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Tap forgot password link
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      // Verify we're on the reset password page
      expect(find.text('Reset Password'), findsOneWidget);

      // Test empty email submission
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email format
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Register navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Tap register link
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Verify we're on the register page
      expect(find.text('Register'), findsOneWidget);
    });
  });

  group('Google Sign In Tests', () {
    testWidgets('Successful Google Sign In', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      final googleSignInButton = find.byKey(const Key('google_sign_in_button'));
      expect(googleSignInButton, findsOneWidget);
      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();
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
