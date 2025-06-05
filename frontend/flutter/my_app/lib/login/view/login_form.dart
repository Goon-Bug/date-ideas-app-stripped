import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/login/widgets/login_widgets.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:date_spark_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  NavigatorState get navigator => navigatorKey.currentState!;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status.isFailure,
      listener: (context, state) {
        // Only show the SnackBar if the state has just transitioned to a failure
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (_usernameController.text != state.email.value) {
            _usernameController.text = state.email.value;
          }
          if (_passwordController.text != state.password.value) {
            _passwordController.text = state.password.value;
          }

          return Card(
            color: Theme.of(context).colorScheme.primary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: ListView(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      Image.asset(
                        'assets/images/LoginTitle.png',
                        height: screenHeight * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                      SizedBox(height: screenHeight * 0.030),
                      Text(
                        'Date night inspiration at your fingertips!',
                        style: TextStyle(fontSize: screenHeight * 0.035),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      CustomInputField(
                        controller: _usernameController,
                        labelText: 'Email',
                        errorMessage: state.email.isNotValid
                            ? Email.getErrorMessage(context.select(
                                (LoginBloc bloc) =>
                                    bloc.state.email.displayError))
                            : null,
                        obscureText: false, // Email field should not be obscure
                        onChanged: (email) {
                          context
                              .read<LoginBloc>()
                              .add(LoginEmailChanged(email));
                        },
                      ),
                      const Padding(padding: EdgeInsets.all(12)),
                      CustomInputField(
                        controller: _passwordController,
                        labelText: 'Password',
                        errorMessage: state.password.isNotValid
                            ? Password.getErrorMessage(context.select(
                                (LoginBloc bloc) =>
                                    bloc.state.password.displayError))
                            : null,
                        obscureText: true, // Password field should be obscure
                        onChanged: (password) {
                          context
                              .read<LoginBloc>()
                              .add(LoginPasswordChanged(password));
                        },
                      ),
                      const Padding(padding: EdgeInsets.all(12)),
                      const LoginButton(),
                      SizedBox(height: screenHeight * 0.005),
                      Column(
                        children: [
                          TextButton(
                            key: const Key('registerLinkButton'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              navigator.pushReplacementNamed('/register');
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
