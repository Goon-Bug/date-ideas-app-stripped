import 'package:date_spark_app/register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (RegisterBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    final isValid = context.select((RegisterBloc bloc) => bloc.state.isValid);

    return ElevatedButton(
      key: const Key('submitButton'),
      onPressed: isValid && !isInProgressOrSuccess
          ? () => context.read<RegisterBloc>().add(const RegisterSubmitted())
          : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.surface,
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
          : Text('Submit',
              style: TextStyle(
                  fontFamily: 'RetroSmall',
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}
