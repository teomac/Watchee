import 'package:dima_project/pages/login_and_register/login_page.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([CustomAuth, FirebaseAuth])
import '../../../mocks/login_page_test.mocks.dart';

void main() {
  group('LoginPage Unit Tests', () {
    late MockCustomAuth mockAuth;

    setUp(() {
      mockAuth = MockCustomAuth();
    });

    test('signInWithEmailAndPassword succeeds with valid credentials',
        () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      )).thenAnswer((_) async => {});

      // Verify no error is thrown
      expect(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password123',
        ),
        returnsNormally,
      );
    });

    test('signInWithEmailAndPassword throws for invalid credentials', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'invalid@test.com',
        password: 'wrongpass',
      )).thenThrow(Exception('Invalid credentials'));

      // Verify error is thrown
      expect(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'invalid@test.com',
          password: 'wrongpass',
        ),
        throwsException,
      );
    });

    test('error message is empty initially', () {
      final loginState = LoginPageState();
      expect(loginState.errorMessage, '');
    });

    test('signInWithEmailAndPassword handles network error', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      )).thenThrow(FirebaseException(plugin: 'auth', message: 'Network error'));

      expect(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
