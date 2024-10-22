import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/pages/login_and_register/register_page.dart';

void main() {
  late RegisterPageState pageState;

  setUp(() {
    pageState = RegisterPageState();
  });

  group('Password Validation Tests', () {
    test('valid password should pass all criteria', () {
      const validPassword = 'Password1!';
      expect(pageState.isPasswordValid(validPassword), true);
    });

    test('password without uppercase should fail', () {
      const invalidPassword = 'password1!';
      expect(pageState.isPasswordValid(invalidPassword), false);
    });

    test('password without number should fail', () {
      const invalidPassword = 'Password!';
      expect(pageState.isPasswordValid(invalidPassword), false);
    });

    test('password without special character should fail', () {
      const invalidPassword = 'Password1';
      expect(pageState.isPasswordValid(invalidPassword), false);
    });

    test('password less than 8 characters should fail', () {
      const invalidPassword = 'Pass1!';
      expect(pageState.isPasswordValid(invalidPassword), false);
    });
  });

  group('Email Validation Tests', () {
    test('valid email should pass validation', () {
      const validEmail = 'test@example.com';
      expect(pageState.isEmailValid(validEmail), true);
    });

    test('email without @ should fail', () {
      const invalidEmail = 'testexample.com';
      expect(pageState.isEmailValid(invalidEmail), false);
    });

    test('email without domain should fail', () {
      const invalidEmail = 'test@';
      expect(pageState.isEmailValid(invalidEmail), false);
    });

    test('email with invalid characters should fail', () {
      const invalidEmail = 'test@example.com#';
      expect(pageState.isEmailValid(invalidEmail), false);
    });

    test('empty email should fail', () {
      const invalidEmail = '';
      expect(pageState.isEmailValid(invalidEmail), false);
    });
  });
}
