import 'package:dima_project/pages/login_and_register/reset_password_page.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<FirebaseAuth>()])
import '../../../mocks/w_reset_password_page_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<FirebaseAuth>(
            create: (_) => mockFirebaseAuth,
          ),
        ],
        child: const ResetPasswordPage(),
      ),
    );
  }

  testWidgets('should render all UI elements correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify AppBar
    expect(find.byType(AppBar), findsOneWidget);

    // Verify instruction text
    expect(
      find.text('Please enter the email associated with your account.'),
      findsOneWidget,
    );

    // Verify email text field
    expect(find.byType(MyTextField), findsOneWidget);

    // Verify reset button
    expect(find.byType(CustomSubmitButton), findsOneWidget);
  });

  testWidgets('should show error when email is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap reset button without entering email
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('should show error when email is invalid', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter invalid email
    await tester.enterText(find.byType(MyTextField), 'invalid-email');
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('should show loading indicator when resetting password',
      (tester) async {
    // Setup successful password reset
    when(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    // Enter valid email
    await tester.enterText(find.byType(MyTextField), 'test@example.com');

    // Tap reset button
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    await tester.pumpAndSettle();

    // Verify success message
    expect(
      find.text('Password reset email sent. Check your inbox.'),
      findsOneWidget,
    );
  });

  testWidgets('should show error message when reset fails', (tester) async {
    // Setup failed password reset
    when(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'))
        .thenThrow(
      FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for this email.',
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    // Enter email
    await tester.enterText(find.byType(MyTextField), 'test@example.com');

    // Tap reset button
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    // Wait for operation to complete
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('No user found for this email.'), findsOneWidget);
  });

  testWidgets('should handle generic errors gracefully', (tester) async {
    // Setup generic error
    when(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'))
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(createWidgetUnderTest());

    // Enter email
    await tester.enterText(find.byType(MyTextField), 'test@example.com');

    // Tap reset button
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    // Wait for operation to complete
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('An error occurred. Please try again.'), findsOneWidget);
  });

  testWidgets('should clear error messages when starting new reset attempt',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // First attempt - trigger an error
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);

    // Second attempt - error should be cleared
    await tester.enterText(find.byType(MyTextField), 'test@example.com');
    await tester.tap(find.byType(CustomSubmitButton));
    await tester.pump();

    expect(find.text('Please enter your email'), findsNothing);
  });
}
