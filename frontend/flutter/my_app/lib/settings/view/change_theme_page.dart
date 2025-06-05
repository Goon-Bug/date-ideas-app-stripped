import 'package:date_spark_app/settings/blocs/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangeThemePage extends StatelessWidget {
  const ChangeThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Change Theme',
        style: TextStyle(fontSize: 28),
      )),
      body: BlocBuilder<ThemeCubit, ColorScheme>(
        builder: (context, theme) {
          return ListView(
            children: [
              for (var entry in themes)
                ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(fontSize: 22),
                  ), // Theme name
                  leading: Radio<ColorScheme>(
                    value: entry.value,
                    groupValue: theme,
                    onChanged: (ColorScheme? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().updateTheme(value);
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
