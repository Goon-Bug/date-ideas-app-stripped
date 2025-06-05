part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

final class AuthenticationSubscriptionRequested extends AuthenticationEvent {}

final class AuthenticationUserUpdated extends AuthenticationEvent {}

final class AuthenticationLogIn extends AuthenticationEvent {
  const AuthenticationLogIn(this.user);

  final User user;

  @override
  List<Object> get props => [user];
  
}

final class AuthenticationUnauthenticated extends AuthenticationEvent {}

final class AuthenticationLogoutPressed extends AuthenticationEvent {}
