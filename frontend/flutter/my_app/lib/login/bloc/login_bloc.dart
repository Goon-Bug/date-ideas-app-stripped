import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/services/api/utils/exceptions.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
    required AuthenticationBloc
        authenticationBloc, // Pass AuthenticationBloc in the constructor
  })  : _authenticationRepository = authenticationRepository,
        _authenticationBloc = authenticationBloc,
        super(const LoginState()) {
    on<LoginReset>(_onReset);
    on<LoginEmailChanged>(_onEmailChanged); // Corrected method name
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;
  final AuthenticationBloc _authenticationBloc;

  void _onReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.password, email]),
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([password, state.email]),
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        final user = await _authenticationRepository.logIn(
          state.email.value,
          state.password.value,
        );
        _authenticationBloc.add(AuthenticationLogIn(user));
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (e, stackTrace) {
        log('Error: $e');
        log('Stack Trace: $stackTrace');
        final errorMessage = e is ApiException
            ? e.message
            : 'An unexpected error occurred. Please try again.';
        emit(state.copyWith(
          errorMessage: errorMessage,
          status: FormzSubmissionStatus.failure,
          email: const Email.pure(),
          password: const Password.pure(),
        ));
      }
    }
  }
}
