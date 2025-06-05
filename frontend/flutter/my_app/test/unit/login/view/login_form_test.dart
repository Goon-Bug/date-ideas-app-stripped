// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:date_spark_app/login/view/login_form.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  group('LoginForm', () {
    late LoginBloc loginBloc;

    setUp(() {
      loginBloc = MockLoginBloc();
    });

    testWidgets('adds LoginEmailChanged to LoginBloc when email is updated',
        (tester) async {
      const email = 'email@email.com';
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('emailInput')),
        email,
      );
      verify(
        () => loginBloc.add(const LoginEmailChanged(email)),
      ).called(1);
    });

    testWidgets(
        'adds LoginPasswordChanged to LoginBloc when password is updated',
        (tester) async {
      const password = 'password';
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('passwordInput')),
        password,
      );
      verify(
        () => loginBloc.add(const LoginPasswordChanged(password)),
      ).called(1);
    });

    testWidgets('login button is disabled by default', (tester) async {
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets(
        'loading indicator is shown when status is submission in progress',
        (tester) async {
      when(() => loginBloc.state).thenReturn(
        const LoginState(status: FormzSubmissionStatus.inProgress),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('login button is enabled when status is validated',
        (tester) async {
      when(() => loginBloc.state).thenReturn(const LoginState(isValid: true));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isTrue);
    });

    testWidgets('LoginSubmitted is added to LoginBloc when continue is tapped',
        (tester) async {
      when(() => loginBloc.state).thenReturn(const LoginState(isValid: true));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      verify(() => loginBloc.add(const LoginSubmitted())).called(1);
    });

    testWidgets('shows SnackBar when status is submission failure',
        (tester) async {
      whenListen(
        loginBloc,
        Stream.fromIterable([
          const LoginState(status: FormzSubmissionStatus.inProgress),
          const LoginState(status: FormzSubmissionStatus.failure),
        ]),
        initialState: const LoginState(status: FormzSubmissionStatus.failure),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('navigates to register page when Register button is tapped',
        (WidgetTester tester) async {
      when(() => loginBloc.state).thenReturn(const LoginState());

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
          routes: {
            '/register': (context) => const Scaffold(body: Text('Register')),
          },
        ),
      );

      await tester.tap(find.byKey(const Key('registerLinkButton')));
      await tester.pumpAndSettle();

      expect(find.text('Register'), findsOneWidget);
    });
  });
}
