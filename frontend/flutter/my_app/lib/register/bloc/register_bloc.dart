import 'package:bloc/bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/password_verify.dart';
import 'package:date_spark_app/services/api/utils/exceptions.dart';
import 'package:date_spark_app/widgets/input_validations/username.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:date_spark_app/register/register_reposository/register_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthenticationRepository authenticationRepository,
    required RegisterRepository registerRepository,
  })  : _authenticationRepository = authenticationRepository,
        _registerRepository = registerRepository,
        super(const RegisterState()) {
    on<RegisterReset>(_onReset);
    on<RegisterUsernameChanged>(_onUsernameChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterPasswordVerificationChanged>(_onPasswordVerificationChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  // ignore: unused_field
  final AuthenticationRepository _authenticationRepository;
  final RegisterRepository _registerRepository;

  void _onReset(
    RegisterReset event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterState());
  }

  void _onUsernameChanged(
    RegisterUsernameChanged event,
    Emitter<RegisterState> emit,
  ) {
    final username = Username.dirty(event.username);
    emit(
      state.copyWith(
        username: username,
        isValid: Formz.validate(
            [state.password, username, state.email, state.passwordVerify]),
      ),
    );
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final password = Password.dirty(event.password);
    final passwordVerify = PasswordVerification.dirty(
      value: state.passwordVerify.value,
      password: password.value,
    );
    emit(
      state.copyWith(
        password: password,
        passwordVerify: passwordVerify,
        isValid: Formz.validate(
            [password, passwordVerify, state.username, state.email]),
      ),
    );
  }

  void _onPasswordVerificationChanged(
      RegisterPasswordVerificationChanged event, Emitter<RegisterState> emit) {
    final passwordVerify = PasswordVerification.dirty(
        value: event.passwordVerify, password: state.password.value);
    emit(state.copyWith(
      passwordVerify: passwordVerify,
      isValid: Formz.validate(
          [state.password, passwordVerify, state.username, state.email]),
    ));
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate(
            [email, state.username, state.password, state.passwordVerify]),
      ),
    );
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _registerRepository.register(
          state.username.value,
          state.password.value,
          state.email.value,
        );

        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (e) {
        final error = e as ApiException;
        emit(state.copyWith(
          errorMessage: error.message,
          status: FormzSubmissionStatus.failure,
          username: const Username.pure(),
          password: const Password.pure(),
          passwordVerify: const PasswordVerification.pure(),
          email: const Email.pure(),
        ));
        add(const RegisterReset());
      }
    }
  }
}
