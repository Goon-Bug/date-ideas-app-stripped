import 'package:bloc_test/bloc_test.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/register/bloc/register_bloc.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/password_verify.dart';
import 'package:date_spark_app/register/register_reposository/register_repository.dart';
import 'package:date_spark_app/services/api/index.dart';
import 'package:date_spark_app/widgets/input_validations/username.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterRepository extends Mock implements RegisterRepository {}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late RegisterRepository registerRepository;
  late AuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    registerRepository = MockRegisterRepository();
  });

  group('RegisterBloc', () {
    test('initial state is RegisterState', () {
      final registerBloc = RegisterBloc(
          authenticationRepository: authenticationRepository,
          registerRepository: registerRepository);
      expect(registerBloc.state, const RegisterState());
    });
    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterState] with initial values when RegisterReset is added, resetting all fields',
      build: () => RegisterBloc(
        authenticationRepository: authenticationRepository,
        registerRepository: registerRepository,
      ),
      seed: () => const RegisterState(
        username: Username.dirty('existing_username'),
        password: Password.dirty('Password1!'),
        passwordVerify: PasswordVerification.dirty(
            value: 'Password1!', password: 'Password1!'),
        email: Email.dirty('email@email.com'),
      ),
      act: (bloc) => bloc.add(const RegisterReset()),
      expect: () => const <RegisterState>[
        RegisterState(),
      ],
    );

    group('RegisterSubmitted', () {
      const username = 'username';
      const password = 'Password1!';
      const email = 'email@email.com';

      blocTest<RegisterBloc, RegisterState>(
        'emits [submissionInProgress, submissionSuccess] when register succeeds',
        setUp: () {
          when(() => registerRepository.register(username, password, email))
              .thenAnswer((_) => Future<String>.value('user'));
        },
        build: () => RegisterBloc(
          authenticationRepository: authenticationRepository,
          registerRepository: registerRepository,
        ),
        act: (bloc) {
          bloc
            ..add(const RegisterUsernameChanged(username))
            ..add(const RegisterPasswordChanged(password))
            ..add(const RegisterPasswordVerificationChanged(password))
            ..add(const RegisterEmailChanged(email))
            ..add(const RegisterSubmitted());
        },
        expect: () => const <RegisterState>[
          RegisterState(username: Username.dirty(username)),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify: PasswordVerification.dirty(
                value: '',
                password:
                    password), // turns dirty because of the validation check on verify input when user inputs into password field
            isValid: false,
          ),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            isValid: false,
          ),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            email: Email.dirty(email),
            isValid: true,
          ),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            email: Email.dirty(email),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            email: Email.dirty(email),
            isValid: true,
            status: FormzSubmissionStatus.success,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterInProgress, RegisterFailure] when register fails',
        setUp: () {
          when(
            () => registerRepository.register(username, password, email),
          ).thenThrow(ApiException('Error'));
        },
        build: () => RegisterBloc(
          authenticationRepository: authenticationRepository,
          registerRepository: registerRepository,
        ),
        act: (bloc) {
          bloc
            ..add(const RegisterUsernameChanged(username))
            ..add(const RegisterPasswordChanged(password))
            ..add(const RegisterPasswordVerificationChanged(password))
            ..add(const RegisterEmailChanged(email))
            ..add(const RegisterSubmitted());
        },
        expect: () => const <RegisterState>[
          RegisterState(
            username: Username.dirty('username'),
          ),
          RegisterState(
            username: Username.dirty('username'),
            password: Password.dirty('Password1!'),
            passwordVerify:
                PasswordVerification.dirty(value: '', password: password),
            isValid: false,
          ),
          RegisterState(
            username: Username.dirty(username),
            password: Password.dirty(password),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            isValid: false,
          ),
          RegisterState(
            username: Username.dirty('username'),
            password: Password.dirty('Password1!'),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            email: Email.dirty(email),
            isValid: true,
          ),
          RegisterState(
            username: Username.dirty('username'),
            password: Password.dirty('Password1!'),
            passwordVerify:
                PasswordVerification.dirty(value: password, password: password),
            email: Email.dirty(email),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          RegisterState(
            username: Username.pure(),
            password: Password.pure(),
            passwordVerify: PasswordVerification.pure(),
            email: Email.pure(),
            isValid: false,
            errorMessage: 'Error',
            status: FormzSubmissionStatus.failure,
          ),
          RegisterState(),
        ],
      );
    });
  });
}
