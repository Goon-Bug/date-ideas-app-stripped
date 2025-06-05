// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/widgets/input_validations/username.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usernameString = 'mock-username';
  group('Username', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final username = Username.pure();
        expect(username.value, '');
        expect(username.isPure, isTrue);
      });

      test('dirty creates correct instance', () {
        final username = Username.dirty(usernameString);
        expect(username.value, usernameString);
        expect(username.isPure, isFalse);
      });
    });

    group('validator', () {
      test('returns empty error when username is empty', () {
        expect(
          Username.dirty().error,
          UsernameValidationError.empty,
        );
      });

      test('is valid when username is not empty and more than 4 characters',
          () {
        expect(
          Username.dirty(usernameString).error,
          isNull,
        );
      });

      test('too short error when username is less than 4 characters', () {
        expect(
          Username.dirty('use').error,
          UsernameValidationError.tooShort,
        );
      });

      test('too long error when username is more than 20 characters', () {
        expect(
          Username.dirty('qwertyuiopasdfghjklzx').error,
          UsernameValidationError.tooLong,
        );
      });

      test('contains space error when username has a space', () {
        expect(
          Username.dirty('user name').error,
          UsernameValidationError.containsSpaces,
        );
      });
    });
  });
}
