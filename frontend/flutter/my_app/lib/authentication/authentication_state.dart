part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = User.empty,
    this.errorMessage,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(User user, {String? errorMessage})
      : this._(
          status: AuthenticationStatus.authenticated,
          user: user,
          errorMessage: errorMessage,
        );

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final User user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
