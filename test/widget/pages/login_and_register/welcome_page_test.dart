import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/pages/login_and_register/welcome_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../unit/pages/login_and_register/welcome_page_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockImagePicker mockImagePicker;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockUserService = MockUserService();
    mockImagePicker = MockImagePicker();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
  });

  testWidgets('WelcomeScreen shows all required elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Verify presence of key elements
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Username *'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Form validation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Try to submit empty form
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill in all fields'), findsOneWidget);

    // Fill in only username
    await tester.enterText(find.byType(TextField).last, 'testuser');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill in all fields'), findsOneWidget);

    // Fill in both fields
    await tester.enterText(find.byType(TextField).first, 'Test User');
    await tester.enterText(find.byType(TextField).last, 'testuser');

    when(mockUserService.isUsernameAvailable('testuser'))
        .thenAnswer((_) async => true);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  });

  testWidgets('Username availability check works', (WidgetTester tester) async {
    when(mockUserService.isUsernameAvailable('taken'))
        .thenAnswer((_) async => false);
    when(mockUserService.isUsernameAvailable('available'))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Test taken username
    await tester.enterText(find.byType(TextField).last, 'taken');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Username is not available'), findsOneWidget);

    // Test available username
    await tester.enterText(find.byType(TextField).last, 'available');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Username is available'), findsOneWidget);
  });

  testWidgets('Image picker shows when camera icon is tapped',
      (WidgetTester tester) async {
    final mockXFile = XFile('test/path/image.jpg');
    when(mockImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => mockXFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
  });

  testWidgets('Form submission shows loading indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Fill form with valid data
    await tester.enterText(find.byType(TextField).first, 'Test User');
    await tester.enterText(find.byType(TextField).last, 'testuser');

    when(mockUserService.isUsernameAvailable('testuser'))
        .thenAnswer((_) async => true);

    // Submit form
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error handling shows snackbar', (WidgetTester tester) async {
    when(mockUserService.updateUserWithNameLowerCase(any, any))
        .thenThrow(Exception('Test error'));

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Fill and submit form
    await tester.enterText(find.byType(TextField).first, 'Test User');
    await tester.enterText(find.byType(TextField).last, 'testuser');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text('An error occurred: Exception: Test error'), findsOneWidget);
  });
}
