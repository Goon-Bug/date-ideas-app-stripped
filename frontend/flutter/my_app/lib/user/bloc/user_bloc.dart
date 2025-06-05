import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:date_spark_app/user/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UserInitial()) {
    on<UpdateUserProfileIcon>(_onUpdateUserProfileIcon);
    on<UpdateUserUsername>(_onUpdateUserUsername);
    on<UpdateUserPassword>(_onUpdateUserPassword);
    on<UpdateUserTokens>(_onUpdateToken);
    on<ClearUserBlocState>(_onClearUserBlocState);
  }

  Future<void> _onUpdateUserProfileIcon(
      UpdateUserProfileIcon event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      log('Updating user profile icon to: ${event.newIconPath}',
          name: 'UserBloc');
      await _userRepository.updateProfileIcon(event.newIconPath);

      final updatedUser = await _userRepository.getUser();
      log("Updated User in User Bloc: $updatedUser");
      if (updatedUser != null) {
        emit(UserUpdated(
            timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
      } else {
        log('No user object when updating user icon');
      }

      log('Profile icon updated successfully. User: ${updatedUser!.username}',
          name: 'UserBloc');
    } catch (e) {
      log('Error updating profile icon: $e', name: 'UserBloc');
      emit(UserUpdateError('Failed to update profile icon: $e'));
    }
  }

  Future<void> _onUpdateUserUsername(
      UpdateUserUsername event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      log('Attempting to update username to: ${event.newUsername}',
          name: 'UserBloc');

      final result = await _userRepository.updateUsername(event.newUsername);

      if (result.isSuccess) {
        final updatedUser = await _userRepository.getUser();
        if (updatedUser != null) {
          emit(UserUpdated(
              timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
          log('Username updated successfully in UserBloc. User: ${updatedUser.username}',
              name: 'UserBloc');
        } else {
          emit(UserUpdateError('Failed to retrieve updated user details.',
              timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
          log('Error: Updated user data could not be retrieved.',
              name: 'UserBloc');
        }
      } else {
        emit(
          UserUpdateError(
            '${result.error ?? 'Failed to update username.'} [${DateTime.now().toIso8601String()}]',
          ),
        );
        log('Error updating username: ${result.error}', name: 'UserBloc');
      }
    } catch (e, stackTrace) {
      emit(UserUpdateError('An unexpected error occurred: $e',
          timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
      log('Exception occurred during username update: $e',
          error: e, stackTrace: stackTrace, name: 'UserBloc');
    }
  }

  Future<void> _onUpdateUserPassword(
      UpdateUserPassword event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      log('Attempting to update password for user', name: 'UserBloc');

      final result = await _userRepository.updatePassword(event.newPassword);

      if (result.isSuccess) {
        final updatedUser = await _userRepository.getUser();
        if (updatedUser != null) {
          emit(UserUpdated(
              timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
          log('Password updated successfully for user: ${updatedUser.username}',
              name: 'UserBloc');
        } else {
          emit(UserUpdateError('Failed to retrieve updated user details.',
              timestamp: DateTime.now().millisecondsSinceEpoch.toString()));
          log('Error: Updated user data could not be retrieved.',
              name: 'UserBloc');
        }
      } else {
        emit(
          UserUpdateError(
            '${result.error ?? 'Failed to update password.'} [${DateTime.now().toIso8601String()}]',
          ),
        );
        log('Error updating password: ${result.error}', name: 'UserBloc');
      }
    } catch (e, stackTrace) {
      emit(UserUpdateError(
          'An unexpected error occurred while updating the password: $e'));
      log('Exception occurred during password update: $e',
          error: e, stackTrace: stackTrace, name: 'UserBloc');
    }
  }

  Future<void> _onUpdateToken(
      UpdateUserTokens event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      log('Updating user token count by: ${event.newTokens}', name: 'UserBloc');

      final user = await _userRepository.getUser();
      final updatedUser = user?.copyWith(tokenCount: event.newTokens);

      log("Updated User in User Bloc: $updatedUser");

      if (updatedUser != null) {
        await _userRepository.updateUserInStorage(updatedUser);
        emit(UserUpdated(
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      } else {
        log('No user object when updating tokens');
      }

      log('Token count updated successfully. User: ${updatedUser!.username}',
          name: 'UserBloc');
    } catch (e) {
      log('Error updating token count: $e', name: 'UserBloc');
      emit(UserUpdateError('Failed to update token count: $e'));
    }
  }

  Future<void> _onClearUserBlocState(
      ClearUserBlocState event, Emitter<UserState> emit) async {
    emit(UserInitial());
  }
}
