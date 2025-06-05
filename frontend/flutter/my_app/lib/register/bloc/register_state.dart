part of 'register_bloc.dart';

final class RegisterState extends Equatable {
  const RegisterState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.passwordVerify = const PasswordVerification.pure(),
    this.email = const Email.pure(),
    this.isValid = false,
    this.errorMessage = '',
  });

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;
  final PasswordVerification passwordVerify;
  final Email email;
  final bool isValid;
  final String errorMessage;

  RegisterState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
    PasswordVerification? passwordVerify,
    Email? email,
    bool? isValid,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordVerify: passwordVerify ?? this.passwordVerify,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props =>
      [status, username, password, passwordVerify, email, errorMessage];
}
