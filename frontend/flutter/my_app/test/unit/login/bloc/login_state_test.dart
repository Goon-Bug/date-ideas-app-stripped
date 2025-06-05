// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

void main() {
  const email = Email.dirty('email@email.com');
  const password = Password.dirty('Password1!');
  group('LoginState', () {
    test('supports value comparisons', () {
      expect(LoginState(), LoginState());
    });

    test('returns same object when no properties are passed', () {
      expect(LoginState().copyWith(), LoginState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        LoginState().copyWith(status: FormzSubmissionStatus.initial),
        LoginState(),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        LoginState().copyWith(email: email),
        LoginState(email: email),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        LoginState().copyWith(password: password),
        LoginState(password: password),
      );
    });
  });
}
