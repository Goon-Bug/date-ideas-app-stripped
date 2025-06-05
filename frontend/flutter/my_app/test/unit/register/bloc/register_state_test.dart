// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/register/bloc/register_bloc.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/password_verify.dart';
import 'package:date_spark_app/widgets/input_validations/username.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

void main() {
  const username = Username.dirty('username');
  const password = Password.dirty('Password1!');
  const passwordVerify =
      PasswordVerification.dirty(value: 'Password1!', password: 'Password1!');
  const email = Email.dirty('email@email.com');
  const errorMessage = 'Mock Error has occured';
  group('RegisterState', () {
    test('supports value comparisons', () {
      expect(RegisterState(), RegisterState());
    });

    test('returns same object when no properties are passed', () {
      expect(RegisterState().copyWith(), RegisterState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        RegisterState().copyWith(status: FormzSubmissionStatus.initial),
        RegisterState(),
      );
    });

    test('returns object with updated username when username is passed', () {
      expect(
        RegisterState().copyWith(username: username),
        RegisterState(username: username),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        RegisterState().copyWith(password: password),
        RegisterState(password: password),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        RegisterState().copyWith(email: email),
        RegisterState(email: email),
      );
    });

    test(
        'returns object with updated passwordVerify when passwordVerify is passed',
        () {
      expect(
        RegisterState().copyWith(passwordVerify: passwordVerify),
        RegisterState(passwordVerify: passwordVerify),
      );
    });
    test('should contain the correct error message when provided', () {
      expect(RegisterState().copyWith(errorMessage: errorMessage),
          RegisterState(errorMessage: errorMessage));
    });

    test('should contain the default error message when no message is provided',
        () {
      final state = RegisterState();
      expect(state.errorMessage, '');
    });

    test('should have isValid as false by default', () {
      final state = RegisterState();
      expect(state.isValid, false);
    });
  });
}
