// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const username = 'username';
  const password = 'Password1!';
  group('LoginEvent', () {
    group('LoginUsernameChanged', () {
      test('supports value comparisons', () {
        expect(LoginEmailChanged(username), LoginEmailChanged(username));
      });
    });

    group('LoginPasswordChanged', () {
      test('supports value comparisons', () {
        expect(LoginPasswordChanged(password), LoginPasswordChanged(password));
      });
    });

    group('LoginSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginSubmitted(), LoginSubmitted());
      });
    });
    group('LoginReset', () {
      test('supports value comparisons', () {
        expect(LoginReset(), LoginReset());
      });
    });
  });
}
