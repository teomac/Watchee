import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/pages/login_and_register/reset_password_page.dart';

@GenerateMocks([FirebaseAuth])
void main() {
  group('ResetPasswordPage Widget Tests', () {
    testWidgets('renders initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
        ),
      );

      // Verify AppBar title
      expect(find.widgetWithText(AppBar, 'Reset Password'), findsOneWidget);
      // Verify TextField is present
      expect(find.byType(TextField), findsOneWidget);
      // Verify reset button
      expect(find.widgetWithText(ElevatedButton, 'Reset Password'),
          findsOneWidget);
      // Verify instruction text
      expect(find.text('Please enter the email associated with your account.'),
          findsOneWidget);
      // Verify no error or success messages initially
      expect(find.text('Password reset email sent. Check your inbox.'),
          findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('clears error message when starting new reset attempt',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(),
        ),
      );

      // Set initial error state
      await tester.enterText(find.byType(TextField), 'invalid@email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Start new attempt
      await tester.enterText(find.byType(TextField), 'valid@email.com');
      await tester.pump();

      expect(find.text('user-not-found'), findsNothing);
    });
  });
}
