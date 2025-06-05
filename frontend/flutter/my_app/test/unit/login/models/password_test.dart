// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const passwordString = 'mock-Password1';
  group('Password', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final password = Password.pure();
        expect(password.value, '');
        expect(password.isPure, isTrue);
      });

      test('dirty creates correct instance', () {
        final password = Password.dirty(passwordString);
        expect(password.value, passwordString);
        expect(password.isPure, isFalse);
      });
    });

    group('validator', () {
      test('returns empty error when password is empty', () {
        expect(
          Password.dirty().error,
          PasswordValidationError.empty,
        );
      });

      test('is valid when password meets all requirements', () {
        expect(
          Password.dirty(passwordString).error,
          isNull,
        );
      });
      test('too short error when password is less than 8 characters', () {
        expect(
          Password.dirty('!1Abc').error,
          PasswordValidationError.tooShort,
        );
      });

      test('too long error when password is more than 20 characters', () {
        expect(
          Password.dirty('!1Abcdefghijklmnophij').error,
          PasswordValidationError.tooLong,
        );
      });

      test('no uppercase error when password is has no uppercase letter', () {
        expect(
          Password.dirty('!1abcdef').error,
          PasswordValidationError.noUppercase,
        );
      });

      test('no number error when password is has no number', () {
        expect(
          Password.dirty('!Abcdefg').error,
          PasswordValidationError.noNumber,
        );
      });

      test(
          'no special character error when password is has no special character',
          () {
        expect(
          Password.dirty('1Abcdefg').error,
          PasswordValidationError.noSpecialChar,
        );
      });
    });
  });
}
