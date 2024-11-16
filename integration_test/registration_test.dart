import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test account credentials
  final String testEmail =
      'test${DateTime.now().millisecondsSinceEpoch}@test.com';
  const String testPassword = 'Test123!';
  const String testName = 'Test User';
  final String testUsername =
      'testuser${DateTime.now().millisecondsSinceEpoch}';
  final String testUsername2 =
      'testuser2${DateTime.now().millisecondsSinceEpoch}';

  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    // Clean up: delete test user if exists
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: testEmail, password: testPassword),
        );
        await user.delete();
      }
    } catch (e) {
      debugPrint('Error in tearDown: $e');
    }
  });

  Widget createTestableApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeMode(),
      child: MyApp(initialUri: null),
    );
  }

  group('Registration successfull', () {
    testWidgets('Complete registration flow test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Step 1: Navigate to Registration page
      final registerNowButton = find.text('Not a member? Register now');
      await tester.tap(registerNowButton);
      await tester.pumpAndSettle();

      // Step 2: Fill registration form
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find
          .ancestor(
            of: find.text('Password'),
            matching: find.byType(TextField),
          )
          .first;
      final confirmPasswordField =
          find.widgetWithText(TextField, 'Confirm password');

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.enterText(confirmPasswordField, testPassword);

      // Submit registration
      final registerButton = find.byKey(const Key('register_button'));
      await tester.tap(registerButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Fill Welcome page form
      final nameField = find.widgetWithText(TextField, 'Name *');
      final usernameField = find.widgetWithText(TextField, 'Username *');

      await tester.enterText(nameField, testName);
      await tester.enterText(usernameField, testUsername);

      // Wait for username availability check
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final nextButton = find.byKey(const Key('next_button'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 4: Genre Selection
      // Find AppBar title
      final appBarTitle = find.byType(AppBar);
      expect(appBarTitle, findsOneWidget);
      debugPrint('Found AppBar');

      // Find all FilterChips within SingleChildScrollView
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      debugPrint('Found ScrollView');

      final wrapFinder = find.descendant(
        of: scrollView,
        matching: find.byType(Wrap),
      );
      expect(wrapFinder, findsOneWidget);
      debugPrint('Found Wrap widget');

      // Select first three genres using their text labels
      final firstThreeGenres = ['Action', 'Adventure', 'Animation'];
      for (final genre in firstThreeGenres) {
        debugPrint('Attempting to tap genre: $genre');

        // Find the Text widget within FilterChip
        final genreText = find.text(genre);
        expect(genreText, findsOneWidget,
            reason: 'Could not find genre: $genre');

        // Get the center position of the text widget
        final center = tester.getCenter(genreText);

        // Tap at that position
        await tester.tapAt(center);
        await tester.pumpAndSettle();
        debugPrint('Tapped genre: $genre');
      }

      // Find and tap continue button

      final continueButton = find.byKey(const Key('continue_button'));
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      try {
        // Verify we're on the home page
        expect(find.text('Home'), findsOneWidget);

        debugPrint('Registration flow completed successfully');
      } catch (e) {
        // If we get an error, log the current widget tree
        debugDumpApp();
        rethrow;
      }
    });
  });

  group('Registration failed', () {
    testWidgets('Registration with invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Navigate to Registration
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.enterText(
          find
              .ancestor(
                of: find.text('Password'),
                matching: find.byType(TextField),
              )
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('Registration with weak password', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                of: find.text('Password'),
                matching: find.byType(TextField),
              )
              .first,
          'weak');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), 'weak');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Password must be at least 8 characters long, contain 1 uppercase letter, 1 number, and 1 special character.'),
          findsOneWidget);
    });

    testWidgets('Welcome page with empty fields', (WidgetTester tester) async {
      // First complete registration
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                of: find.text('Password'),
                matching: find.byType(TextField),
              )
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to proceed without filling fields
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify error message in snackbar
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('Genre selection with less than 3 genres',
        (WidgetTester tester) async {
      // Complete registration and welcome page first
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Registration
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                of: find.text('Password'),
                matching: find.byType(TextField),
              )
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Welcome page
      await tester.enterText(
          find.widgetWithText(TextField, 'Name *'), testName);
      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), testUsername2);

      // Wait for username availability check
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pumpAndSettle();

      // Step 4: Genre Selection
      // Find AppBar title
      final appBarTitle = find.byType(AppBar);
      expect(appBarTitle, findsOneWidget);
      debugPrint('Found AppBar');

      // Find all FilterChips within SingleChildScrollView
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      debugPrint('Found ScrollView');

      final wrapFinder = find.descendant(
        of: scrollView,
        matching: find.byType(Wrap),
      );
      expect(wrapFinder, findsOneWidget);
      debugPrint('Found Wrap widget');

      // Select first two genres using their text labels
      final firstTwoGenres = ['Action', 'Adventure'];
      for (final genre in firstTwoGenres) {
        debugPrint('Attempting to tap genre: $genre');

        // Find the Text widget within FilterChip
        final genreText = find.text(genre);
        expect(genreText, findsOneWidget,
            reason: 'Could not find genre: $genre');

        // Get the center position of the text widget
        final center = tester.getCenter(genreText);

        // Tap at that position
        await tester.tapAt(center);
        await tester.pumpAndSettle();
      }

      // Verify Continue button is disabled
      final continueButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continue'));
      expect(continueButton.onPressed, isNull);
    });
  });
}
