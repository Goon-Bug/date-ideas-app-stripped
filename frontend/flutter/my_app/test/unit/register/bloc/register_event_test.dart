// ignore_for_file: prefer_const_constructors
import 'package:date_spark_app/register/bloc/register_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const username = 'username';
  const password = 'Password1!';
  group('RegisterEvent', () {
    group('RegisterUsernameChanged', () {
      test('supports value comparisons', () {
        expect(RegisterUsernameChanged(username),
            RegisterUsernameChanged(username));
      });
    });

    group('RegisterPasswordChanged', () {
      test('supports value comparisons', () {
        expect(RegisterPasswordChanged(password),
            RegisterPasswordChanged(password));
      });
    });

    group('RegisterSubmitted', () {
      test('supports value comparisons', () {
        expect(RegisterSubmitted(), RegisterSubmitted());
      });
    });
    group('RegisterReset', () {
      test('supports value comparisons', () {
        expect(RegisterReset(), RegisterReset());
      });
    });
  });
}
