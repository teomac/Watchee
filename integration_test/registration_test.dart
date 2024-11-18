import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
      child: const MyApp(initialUri: null),
    );
  }

  group('Registration UI and Navigation Tests', () {
    testWidgets('Test registration page UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Navigate to registration page
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Verify all UI elements are present
      expect(find.text('Register'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(
          find.widgetWithText(TextField, 'Confirm password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Already have an account? Login now'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.text('Already have an account? Login now'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('Registration Form Validation Tests', () {
    testWidgets('Test empty fields validation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Test empty submission
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('Test invalid email formats', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      final invalidEmails = [
        'notanemail',
        'missing@',
        '@nodomain.com',
        'invalid@email.',
        'spaces in@email.com'
      ];

      for (var email in invalidEmails) {
        await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
        await tester.enterText(
            find
                .ancestor(
                    of: find.text('Password'), matching: find.byType(TextField))
                .first,
            testPassword);
        await tester.enterText(
            find.widgetWithText(TextField, 'Confirm password'), testPassword);

        await tester.tap(find.byKey(const Key('register_button')));
        await tester.pumpAndSettle();

        expect(
            find.text('Please enter a valid email address.'), findsOneWidget);
      }
    });
  });

  group('Welcome Page Tests', () {
    testWidgets('Test name and username validation',
        (WidgetTester tester) async {
      // Complete registration first
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                  of: find.text('Password'), matching: find.byType(TextField))
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test empty fields
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields.'), findsOneWidget);

      // Test name only
      await tester.enterText(
          find.widgetWithText(TextField, 'Name *'), testName);
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields.'), findsOneWidget);

      // Test username only
      await tester.enterText(find.widgetWithText(TextField, 'Name *'), '');
      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), testUsername);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('next_button')));

      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });
  });

  group('Genre Selection Tests', () {
    testWidgets('Test genre selection validation', (WidgetTester tester) async {
      // Complete registration and welcome page first
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                  of: find.text('Password'), matching: find.byType(TextField))
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
          find.widgetWithText(TextField, 'Name *'), testName);
      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), testUsername2);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(FilterChip), findsWidgets);
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Continue'))
              .onPressed,
          isNull);

      // Select one genre
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      // Verify button still disabled with only one selection
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Continue'))
              .onPressed,
          isNull);

      // Select two more genres
      await tester.tap(find.text('Adventure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animation'));
      await tester.pumpAndSettle();

      // Verify button is enabled with three selections
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Continue'))
              .onPressed,
          isNotNull);

      // Test unselecting genre
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      // Verify button is disabled again
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Continue'))
              .onPressed,
          isNull);
    });
  });

  group('Complete Registration Flow', () {
    testWidgets('Successful registration flow test',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), testEmail);
      await tester.enterText(
          find
              .ancestor(
                  of: find.text('Password'), matching: find.byType(TextField))
              .first,
          testPassword);
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm password'), testPassword);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
          find.widgetWithText(TextField, 'Name *'), testName);
      await tester.enterText(
          find.widgetWithText(TextField, 'Username *'), testUsername);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pumpAndSettle();

      // Select three genres
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adventure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animation'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify successful registration
      expect(find.text('Home'), findsOneWidget);
      expect(FirebaseAuth.instance.currentUser, isNotNull);
    });
  });

  group('Terms and Privacy Policy Tests', () {
    testWidgets('Test Terms of Service page access and content',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Not a member? Register now'));
      await tester.pumpAndSettle();

      // Look for and tap Terms of Service link
      final termsLink = find.text('Terms of Service');
      expect(termsLink, findsOneWidget);
      await tester.tap(termsLink);
      await tester.pumpAndSettle();

      // Verify Terms of Service page content
      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);

      // Check for specific sections
      expect(find.text('1. Introduction'), findsOneWidget);
      expect(find.text('2. Data Sources and Attribution'), findsOneWidget);
      expect(find.text('3. User Accounts'), findsOneWidget);

      // Test navigation back
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back on registration page
      expect(find.text('Register'), findsOneWidget);
    });

    group('Terms and Privacy Policy Tests', () {
      testWidgets('Test Terms of Service page access and functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableApp());
        await tester.pumpAndSettle();

        // Navigate to registration
        await tester.tap(find.text('Not a member? Register now'));
        await tester.pumpAndSettle();

        // Look for and tap Terms of Service link
        final termsLink = find.text('Terms of Service');
        expect(termsLink, findsOneWidget);
        await tester.tap(termsLink);
        await tester.pumpAndSettle();

        // Verify Terms of Service page content
        expect(find.text('Terms of Service'), findsWidgets);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Markdown), findsOneWidget);

        // Try to find some specific content sections
        expect(find.text('1. Introduction'), findsOneWidget);
        expect(find.textContaining('TMDB Attribution'), findsOneWidget);

        // Test scrolling
        await tester.dragFrom(const Offset(0, 300), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Test back navigation
        final backButton = find.byType(BackButton);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back on registration page
        expect(find.text('Register'), findsOneWidget);
      });

      testWidgets('Test Privacy Policy page access and functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableApp());
        await tester.pumpAndSettle();

        // Navigate to registration
        await tester.tap(find.text('Not a member? Register now'));
        await tester.pumpAndSettle();

        // Look for and tap Privacy Policy link
        final privacyLink = find.text('Privacy Policy');
        expect(privacyLink, findsOneWidget);
        await tester.tap(privacyLink);
        await tester.pumpAndSettle();

        // Verify Privacy Policy page content
        expect(find.text('Privacy Policy'), findsWidgets);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Markdown), findsOneWidget);

        // Check for specific privacy policy sections
        expect(find.text('1. Introduction'), findsOneWidget);
        expect(find.textContaining('Information We Collect'), findsOneWidget);

        // Test scrolling
        await tester.dragFrom(const Offset(0, 300), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Test back navigation
        final backButton = find.byType(BackButton);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back on registration page
        expect(find.text('Register'), findsOneWidget);
      });

      testWidgets('Test navigation between Terms and Privacy pages',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableApp());
        await tester.pumpAndSettle();

        // Navigate to registration
        await tester.tap(find.text('Not a member? Register now'));
        await tester.pumpAndSettle();

        // Test Terms of Service navigation
        await tester.tap(find.text('Terms of Service'));
        await tester.pumpAndSettle();

        // Verify Terms page content and scroll
        expect(find.byType(Markdown), findsOneWidget);
        await tester.dragFrom(const Offset(0, 300), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Navigate back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Test Privacy Policy navigation
        await tester.tap(find.text('Privacy Policy'));
        await tester.pumpAndSettle();

        // Verify Privacy page content and scroll
        expect(find.byType(Markdown), findsOneWidget);
        await tester.dragFrom(const Offset(0, 300), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Navigate back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Verify final return to registration page
        expect(find.text('Register'), findsOneWidget);
      });

      testWidgets('Test URL launching functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableApp());
        await tester.pumpAndSettle();

        // Navigate to registration
        await tester.tap(find.text('Not a member? Register now'));
        await tester.pumpAndSettle();

        // Navigate to Privacy Policy
        await tester.tap(find.text('Privacy Policy'));
        await tester.pumpAndSettle();

        // Verify Markdown widget is present
        expect(find.byType(Markdown), findsOneWidget);

        // Get the Markdown widget
        final markdownWidget = tester.widget<Markdown>(find.byType(Markdown));

        // Verify onTapLink callback is set
        expect(markdownWidget.onTapLink, isNotNull);

        // Navigate back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      });
    });
  });
}
