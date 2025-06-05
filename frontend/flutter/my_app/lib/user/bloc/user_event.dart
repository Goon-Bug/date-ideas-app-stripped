part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUserProfileIcon extends UserEvent {
  final String newIconPath;

  const UpdateUserProfileIcon(this.newIconPath);

  @override
  List<Object?> get props => [newIconPath];
}

class UpdateUserUsername extends UserEvent {
  final String newUsername;

  const UpdateUserUsername(this.newUsername);

  @override
  List<Object?> get props => [newUsername];
}

class UpdateUserPassword extends UserEvent {
  final String newPassword;

  const UpdateUserPassword(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

class UpdateUserTokens extends UserEvent {
  final int newTokens;

  const UpdateUserTokens(this.newTokens);

  @override
  List<Object?> get props => [newTokens];
}

class ClearUserBlocState extends UserEvent {}
