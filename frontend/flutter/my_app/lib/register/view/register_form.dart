import 'package:date_spark_app/register/bloc/register_bloc.dart';
import 'package:date_spark_app/register/widgets/register_widgets.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:date_spark_app/widgets/input_validations/email.dart';
import 'package:date_spark_app/widgets/input_validations/password.dart';
import 'package:date_spark_app/widgets/input_validations/password_verify.dart';
import 'package:date_spark_app/widgets/input_validations/username.dart';
import 'package:date_spark_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordVerificationController =
      TextEditingController();
  NavigatorState get navigator => navigatorKey.currentState!;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordVerificationController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          // Update controllers only if the value has changed to avoid resetting the cursor
          if (_usernameController.text != state.username.value) {
            _usernameController.text = state.username.value;
          }
          if (_passwordController.text != state.password.value) {
            _passwordController.text = state.password.value;
          }
          if (_passwordVerificationController.text !=
              state.passwordVerify.value) {
            _passwordVerificationController.text = state.passwordVerify.value;
          }
          if (_emailController.text != state.email.value) {
            _emailController.text = state.email.value;
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
                      SizedBox(height: screenHeight * 0.03),
                      Image.asset(
                        'assets/images/RegisterTitle.png',
                        height: screenHeight * 0.15,
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Date night inspiration at your fingertips!',
                        style: TextStyle(fontSize: screenHeight * 0.035),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      CustomInputField(
                        controller: _usernameController,
                        labelText: 'Username',
                        errorMessage: state.username.isNotValid
                            ? Username.getErrorMessage(context.select(
                                (RegisterBloc bloc) =>
                                    bloc.state.username.displayError))
                            : null,
                        onChanged: (username) {
                          context
                              .read<RegisterBloc>()
                              .add(RegisterUsernameChanged(username));
                        },
                      ),
                      const Padding(padding: EdgeInsets.all(6)),
                      CustomInputField(
                        controller: _emailController,
                        labelText: 'Email',
                        errorMessage: state.email.isNotValid
                            ? Email.getErrorMessage(context.select(
                                (RegisterBloc bloc) =>
                                    bloc.state.email.displayError))
                            : null,
                        onChanged: (email) {
                          context
                              .read<RegisterBloc>()
                              .add(RegisterEmailChanged(email));
                        },
                      ),
                      const Padding(padding: EdgeInsets.all(6)),
                      CustomInputField(
                        controller: _passwordController,
                        labelText: 'Password',
                        errorMessage: state.password.isNotValid
                            ? Password.getErrorMessage(context.select(
                                (RegisterBloc bloc) =>
                                    bloc.state.password.displayError))
                            : null,
                        obscureText: true,
                        onChanged: (password) {
                          context
                              .read<RegisterBloc>()
                              .add(RegisterPasswordChanged(password));
                        },
                      ),
                      const Padding(padding: EdgeInsets.all(6)),
                      CustomInputField(
                        controller: _passwordVerificationController,
                        labelText: 'Password Verification',
                        errorMessage: state.passwordVerify.isNotValid
                            ? PasswordVerification.getErrorMessage(
                                context.select((RegisterBloc bloc) =>
                                    bloc.state.passwordVerify.displayError))
                            : null,
                        obscureText: true,
                        onChanged: (password) {
                          context.read<RegisterBloc>().add(
                              RegisterPasswordVerificationChanged(password));
                        },
                      ),
                      const Padding(
                          padding: EdgeInsets.only(top: 14, bottom: 0)),
                      const RegisterButton(),
                      Column(
                        children: [
                          TextButton(
                            key: const Key('loginLinkButton'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              navigator.pushReplacementNamed('/login');
                            },
                            child: Text(
                              'Login',
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
