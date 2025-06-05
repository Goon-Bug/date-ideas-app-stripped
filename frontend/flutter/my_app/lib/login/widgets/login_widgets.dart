import 'package:date_spark_app/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (LoginBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    final isValid = context.select((LoginBloc bloc) => bloc.state.isValid);

    return ElevatedButton(
      key: const Key('loginButton'),
      onPressed: isValid && !isInProgressOrSuccess
          ? () => context.read<LoginBloc>().add(const LoginSubmitted())
          : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor:
            Theme.of(context).colorScheme.secondaryContainer,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        padding: const EdgeInsets.only(left: 55, right: 55, bottom: 2, top: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isInProgressOrSuccess
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text('Login',
              style: TextStyle(
                  fontFamily: 'RetroSmall',
                  fontSize: 28,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface)),
    );
  }
}
