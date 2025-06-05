import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsernameInput extends StatelessWidget {
  final TextEditingController controller;

  const UsernameInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final username =
        context.select((AuthenticationBloc bloc) => bloc.state.user.username);

    return TextField(
      key: const Key('usernameInput'),
      controller: controller,
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(11),
        labelText: username,
        labelStyle: TextStyle(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const PasswordInput(
      {super.key, required this.controller, this.labelText = 'Password'});

  @override
  PasswordInputState createState() => PasswordInputState();
}

class PasswordInputState extends State<PasswordInput> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('passwordInput'),
      controller: widget.controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(11),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
    );
  }
}
