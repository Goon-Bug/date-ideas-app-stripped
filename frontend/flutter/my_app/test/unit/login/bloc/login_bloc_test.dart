import 'package:bloc_test/bloc_test.dart';
import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/services/api/index.dart';
import 'package:date_spark_app/user/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  late AuthenticationRepository authenticationRepository;
  late AuthenticationBloc authenticationBloc;
  const user = User(id: 99, email: 'email@email.com', username: 'testuser');

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    authenticationBloc = MockAuthenticationBloc();
  });

  group('LoginBloc', () {
    test('initial state is LoginState', () {
      final loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        authenticationRepository: authenticationRepository,
      );
      expect(loginBloc.state, const LoginState());
    });
    blocTest<LoginBloc, LoginState>(
      'emits [LoginState] with initial values when LoginReset is added, resetting the username',
      build: () => LoginBloc(
        authenticationBloc: authenticationBloc,
        authenticationRepository: authenticationRepository,
      ),
      seed: () => const LoginState(
        email: Email.dirty('existing_username'),
      ),
      act: (bloc) => bloc.add(const LoginReset()),
      expect: () => const <LoginState>[
        LoginState(),
      ],
    );

    group('LoginSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when login succeeds',
        setUp: () {
          when(
            () => authenticationRepository.logIn(
              'email@email.com',
              'Password1!',
            ),
          ).thenAnswer((_) async => user);
        },
        build: () => LoginBloc(
          authenticationBloc: authenticationBloc,
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) {
          bloc
            ..add(const LoginEmailChanged('email@email.com'))
            ..add(const LoginPasswordChanged('Password1!'))
            ..add(const LoginSubmitted());
        },
        expect: () => const <LoginState>[
          LoginState(email: Email.dirty('email@email.com')),
          LoginState(
            email: Email.dirty('email@email.com'),
            password: Password.dirty('Password1!'),
            isValid: true,
          ),
          LoginState(
            email: Email.dirty('email@email.com'),
            password: Password.dirty('Password1!'),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.dirty('email@email.com'),
            password: Password.dirty('Password1!'),
            isValid: true,
            status: FormzSubmissionStatus.success,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginFailure] when logIn fails',
        setUp: () {
          when(
            () => authenticationRepository.logIn(
              'email@email.com',
              'Password1!',
            ),
          ).thenThrow(ApiException('Error'));
        },
        build: () => LoginBloc(
          authenticationBloc: authenticationBloc,
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) {
          bloc
            ..add(const LoginEmailChanged('email@email.com'))
            ..add(const LoginPasswordChanged('Password1!'))
            ..add(const LoginSubmitted());
        },
        expect: () => const <LoginState>[
          LoginState(
            email: Email.dirty('email@email.com'),
          ),
          LoginState(
            email: Email.dirty('email@email.com'),
            password: Password.dirty('Password1!'),
            isValid: true,
          ),
          LoginState(
            email: Email.dirty('email@email.com'),
            password: Password.dirty('Password1!'),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.pure(),
            password: Password.pure(),
            isValid: false,
            status: FormzSubmissionStatus.failure,
          ),
        ],
      );
    });
  });
}
