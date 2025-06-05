// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:date_spark_app/register/bloc/index.dart';
import 'package:date_spark_app/register/view/register_form.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

void main() {
  group('RegisterForm', () {
    late RegisterBloc registerBloc;

    setUp(() {
      registerBloc = MockRegisterBloc();
    });

    testWidgets(
        'adds RegisterUsernameChanged to RegisterBloc when username is updated',
        (tester) async {
      const username = 'username';
      when(() => registerBloc.state).thenReturn(const RegisterState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('usernameInput')),
        username,
      );
      verify(
        () => registerBloc.add(const RegisterUsernameChanged(username)),
      ).called(1);
    });

    testWidgets(
        'adds RegisterPasswordChanged to RegisterBloc when password is updated',
        (tester) async {
      const password = 'password';
      when(() => registerBloc.state).thenReturn(const RegisterState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('passwordInput')),
        password,
      );
      verify(
        () => registerBloc.add(const RegisterPasswordChanged(password)),
      ).called(1);
    });

    testWidgets(
        'adds RegisterPasswordVerifyChanged to RegisterBloc when passwordVerify is updated',
        (tester) async {
      const password = 'password';
      when(() => registerBloc.state).thenReturn(const RegisterState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('passwordVerificationInput')),
        password,
      );
      verify(
        () => registerBloc
            .add(const RegisterPasswordVerificationChanged(password)),
      ).called(1);
    });
    testWidgets(
        'adds RegisterEmailChanged to RegisterBloc when email is updated',
        (tester) async {
      const email = 'email@email.com';
      when(() => registerBloc.state).thenReturn(const RegisterState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('emailInput')),
        email,
      );
      verify(
        () => registerBloc.add(const RegisterEmailChanged(email)),
      ).called(1);
    });

    testWidgets('submit button is disabled by default', (tester) async {
      when(() => registerBloc.state).thenReturn(const RegisterState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
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
      when(() => registerBloc.state).thenReturn(
        const RegisterState(status: FormzSubmissionStatus.inProgress),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submit button is enabled when status is validated',
        (tester) async {
      when(() => registerBloc.state)
          .thenReturn(const RegisterState(isValid: true));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isTrue);
    });

    testWidgets(
        'RegisterSubmitted is added to RegisterBloc when submit is tapped',
        (tester) async {
      when(() => registerBloc.state)
          .thenReturn(const RegisterState(isValid: true));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      verify(() => registerBloc.add(const RegisterSubmitted())).called(1);
    });

    testWidgets('shows SnackBar when status is submission failure',
        (tester) async {
      whenListen(
        registerBloc,
        Stream.fromIterable([
          const RegisterState(status: FormzSubmissionStatus.inProgress),
          const RegisterState(status: FormzSubmissionStatus.failure),
        ]),
        initialState:
            const RegisterState(status: FormzSubmissionStatus.failure),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('navigates to login page when Login button is tapped',
        (WidgetTester tester) async {
      when(() => registerBloc.state).thenReturn(const RegisterState());

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: BlocProvider.value(
              value: registerBloc,
              child: RegisterForm(),
            ),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );

      await tester.tap(find.byKey(const Key('loginLinkButton')));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
