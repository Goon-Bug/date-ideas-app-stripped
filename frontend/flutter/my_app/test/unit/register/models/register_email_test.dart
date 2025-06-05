// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usernameString = 'mock-email';
  group('email', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final email = Email.pure();
        expect(email.value, '');
        expect(email.isPure, isTrue);
      });

      test('dirty creates correct instance', () {
        final email = Email.dirty(usernameString);
        expect(email.value, usernameString);
        expect(email.isPure, isFalse);
      });
    });

    group('validator', () {
      test('returns empty error when email is empty', () {
        expect(
          Email.dirty().error,
          EmailValidationError.empty,
        );
      });
      test('returns invalid error when email is invalid', () {
        expect(
          Email.dirty('invalidEmailAddress').error,
          EmailValidationError.invalid,
        );
      });
    });
  });
}
