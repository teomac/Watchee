import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/pages/login_and_register/register_page.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Create mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets('Initial UI elements are rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(showLoginPage: () {}),
    ));

    // Verify all essential UI elements are present
    expect(find.text('AnyMovie'), findsOneWidget);
    expect(
        find.byType(TextField), findsNWidgets(3)); // Email + 2 password fields
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Already have an account? Login now'), findsOneWidget);
  });

  testWidgets('Shows error when passwords do not match',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(showLoginPage: () {}),
    ));

    // Enter different passwords
    await tester.enterText(
        find.byType(TextField).at(1), 'Password123!'); // First password field
    await tester.enterText(
        find.byType(TextField).at(2), 'Password456!'); // Confirm password field

    // Trigger registration attempt
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Shows error for invalid email format',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(showLoginPage: () {}),
    ));

    // Enter invalid email
    await tester.enterText(find.byType(TextField).first, 'invalidemail');

    // Enter matching passwords
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');

    // Trigger registration attempt
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('Shows error for invalid password format',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(showLoginPage: () {}),
    ));

    // Enter valid email but invalid password
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(TextField).at(1), 'weak'); // Invalid password
    await tester.enterText(
        find.byType(TextField).at(2), 'weak'); // Same invalid password

    // Trigger registration attempt
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(
        find.text(
            'Password must be at least 8 characters long, contain 1 uppercase letter, 1 number, and 1 special character.'),
        findsOneWidget);
  });

  testWidgets('Navigation to login page works', (WidgetTester tester) async {
    bool loginPageCalled = false;

    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(
        showLoginPage: () {
          loginPageCalled = true;
        },
      ),
    ));

    // Tap the login link
    await tester.tap(find.text('Already have an account? Login now'));
    await tester.pump();

    // Verify navigation callback was called
    expect(loginPageCalled, true);
  });
}
