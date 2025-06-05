import 'package:bloc_test/bloc_test.dart';
import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/user/models/user.dart';
import 'package:date_spark_app/user/user_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  const user = User(id: 1, username: 'test', email: 'email@email.com');
  late AuthenticationRepository authenticationRepository;
  late UserRepository userRepository;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    authenticationRepository = _MockAuthenticationRepository();
    when(
      () => authenticationRepository.status,
    ).thenAnswer((_) => const Stream.empty());
    userRepository = _MockUserRepository();
    when(() => authenticationRepository.isAccessTokenValid())
        .thenAnswer((_) async => false);

    when(() => userRepository.getUser()).thenAnswer((_) async => user);
  });

  AuthenticationBloc buildBloc() {
    return AuthenticationBloc(
      authenticationRepository: authenticationRepository,
      userRepository: userRepository,
    );
  }

  group('AuthenticationBloc', () {
    test('initial state is AuthenticationState.unknown', () {
      final authenticationBloc = buildBloc();
      expect(authenticationBloc.state, const AuthenticationState.unknown());
      authenticationBloc.close();
    });

    group('AuthenticationSubscriptionRequested', () {
      final error =
          Exception('AuthenticationSubscriptionRequested test failed');

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is unauthenticated',
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [authenticated] when status is authenticated',
        setUp: () {
          when(() => authenticationRepository.status).thenAnswer(
            (_) => Stream.value(AuthenticationStatus.authenticated),
          );
          when(() => authenticationRepository.isAccessTokenValid())
              .thenAnswer((_) async => true);
          when(() => userRepository.getUser()).thenAnswer((_) async => user);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.authenticated(user)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is authenticated but getUser fails',
        setUp: () {
          // Mock the status stream to emit authenticated status
          when(() => authenticationRepository.status).thenAnswer(
              (_) => Stream.value(AuthenticationStatus.authenticated));

          // Mock that the access token is valid
          when(() => authenticationRepository.isAccessTokenValid())
              .thenAnswer((_) async => true);

          // Mock the failure of getUser by throwing an exception
          when(() => userRepository.getUser()).thenAnswer(
            (_) async => null,
          );
        },
        build: () => buildBloc(),
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [
          AuthenticationState.unauthenticated(), // Expect unauthenticated state
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is authenticated but getUser returns null',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
          when(() => authenticationRepository.isAccessTokenValid())
              .thenAnswer((_) async => true);
          when(() => userRepository.getUser()).thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unknown] when status is unknown',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.unknown));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [
          AuthenticationState.unauthenticated(),
          AuthenticationState.unknown()
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'adds error when status stream emits an error',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.error(error));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        errors: () => [error],
      );
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unknown] when logout is initiated [unauthenticated] after completion',
        setUp: () {
          when(() => authenticationRepository.status).thenAnswer(
            (_) => Stream.value(AuthenticationStatus.unknown),
          );
          when(() => authenticationRepository.logOut())
              .thenAnswer((_) async => {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationLogoutPressed()),
        expect: () => [
          const AuthenticationState.unknown(),
          const AuthenticationState.unauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unknown] when logout is initiated [authenticated] after completion',
        setUp: () {
          when(() => authenticationRepository.logOut())
              .thenThrow(Exception('Logout failed'));
        },
        build: buildBloc,
        act: (bloc) => {
          bloc.emit(const AuthenticationState.authenticated(user)),
          bloc.add(AuthenticationLogoutPressed())
        },
        expect: () => [
          const AuthenticationState.authenticated(user),
          const AuthenticationState.unknown(),
          isA<AuthenticationState>()
              .having((state) => state.user, 'user', user)
              .having((state) => state.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });
  });

  group('AuthenticationFunctions', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [authenticated] when access token is valid',
      setUp: () {
        when(() => authenticationRepository.status).thenAnswer(
          (_) => Stream.value(AuthenticationStatus.authenticated),
        );
        when(() => authenticationRepository.isAccessTokenValid()).thenAnswer(
          (_) async {
            return true;
          },
        );
        when(() => userRepository.getUser()).thenAnswer((_) async => user);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
      expect: () => const [AuthenticationState.authenticated(user)],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unauthenticated] when access token is expired',
      setUp: () {
        when(() => authenticationRepository.status).thenAnswer(
          (_) => Stream.value(AuthenticationStatus.authenticated),
        );
        when(() => userRepository.getUser()).thenAnswer((_) async => user);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
      expect: () => const [AuthenticationState.unauthenticated()],
    );
  });
}
