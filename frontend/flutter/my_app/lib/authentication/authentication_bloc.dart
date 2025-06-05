import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:date_spark_app/main_common.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:equatable/equatable.dart';

import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/user/models/user.dart';
import 'package:date_spark_app/user/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthenticationLogoutPressed>(_onLogoutPressed);
    on<AuthenticationUserUpdated>(_onUserUpdate);
    on<AuthenticationLogIn>(_onLogIn);
    on<AuthenticationUnauthenticated>(_onUnauthenticated);
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final storage = SecureStorage();

  Future<void> _onSubscriptionRequested(
    AuthenticationSubscriptionRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    final isValidToken = await _authenticationRepository.isAccessTokenValid();
    final user = isValidToken ? await _userRepository.getUser() : null;

    if (user != null) {
      log('User found in storage with a valid token: $user');
      emit(AuthenticationState.authenticated(user));
    } else {
      log('No valid user in storage or token is invalid');
      emit(const AuthenticationState.unauthenticated());
    }

    await emit.onEach<AuthenticationStatus>(
      _authenticationRepository.status,
      onData: (status) async {
        switch (status) {
          case AuthenticationStatus.unauthenticated:
            log('Authentication status changed to unauthenticated');
            _onLogoutPressed;
            emit(const AuthenticationState.unauthenticated());
            return;
          case AuthenticationStatus.authenticated:
            log('Authentication status changed to authenticated');
            if (user != null) {
              log('User retrieved successfully: $user');
              emit(AuthenticationState.authenticated(user));
            } else {
              log('No user found, emitting unauthenticated');
              emit(const AuthenticationState.unauthenticated());
            }
            return;
          case AuthenticationStatus.unknown:
            log('Authentication status changed to unknown');
            emit(const AuthenticationState.unknown());
            return;
        }
      },
      onError: (error, stackTrace) {
        log('Error occurred while listening to authentication status: $error');
        addError(error, stackTrace);
      },
    );
  }

  Future<void> _onLogoutPressed(
    AuthenticationLogoutPressed event,
    Emitter<AuthenticationState> emit,
  ) async {
    final currentUser = state.user;
    emit(const AuthenticationState.unknown());
    try {
      await _authenticationRepository.logOut();
      getIt<TokenCubit>().updateBackendTokenCount();
      log('Logout successful');
      emit(const AuthenticationState.unauthenticated());
      await storage.printAllSecureStorage();
    } catch (e) {
      log("Logout failed: $e");
      emit(AuthenticationState.authenticated(
        currentUser,
        errorMessage:
            'Logout Failed. Please make sure you\'re connected to the network and try again. (${DateTime.now()})',
      ));
    }
  }

  Future<void> _onUserUpdate(
    AuthenticationUserUpdated event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (state.status == AuthenticationStatus.authenticated) {
      try {
        final updatedUser = await _userRepository.getUser();

        if (updatedUser != null) {
          emit(AuthenticationState.authenticated(updatedUser));
          log('User updated successfully: $updatedUser');
        } else {
          log('Failed to retrieve updated user. Keeping the current state.');
        }
      } catch (e) {
        log('Error updating user: $e');
      }
    } else {
      log('Attempted to update user while unauthenticated or in unknown state.');
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogIn(
    AuthenticationLogIn event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationState.authenticated(event.user));
  }

  Future<void> _onUnauthenticated(
    AuthenticationUnauthenticated event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.unauthenticated());
  }
}
