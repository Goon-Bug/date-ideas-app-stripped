part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {}

class UserInitial extends UserState {}

class UserUpdated extends UserState {
  final String? timestamp;

  const UserUpdated({this.timestamp});

  @override
  List<Object?> get props => [timestamp ?? ''];
}

class UserPasswordUpdated extends UserState {
  final String message;

  const UserPasswordUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class UserUpdateError extends UserState {
  final String errorMessage;
  final String? timestamp;

  const UserUpdateError(this.errorMessage, {this.timestamp});

  @override
  List<Object?> get props => [errorMessage, timestamp ?? ''];
}
