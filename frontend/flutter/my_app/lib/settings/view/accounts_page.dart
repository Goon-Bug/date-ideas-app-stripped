import 'dart:developer';
import 'package:date_spark_app/helper_functions.dart';
import 'package:date_spark_app/main/bloc/dates_scroller_bloc.dart';
import 'package:date_spark_app/main/tags/tags_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 22),
              ),
              trailing: const Icon(Icons.camera_alt),
              onTap: () async {
                final selectedIconIndex = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ChangeProfilePictureDialog();
                  },
                );
                log('Selected icon index: $selectedIconIndex',
                    name: 'AccountManagementScreen');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeProfilePictureDialog extends StatefulWidget {
  const ChangeProfilePictureDialog({super.key});

  @override
  ChangeProfilePictureDialogState createState() =>
      ChangeProfilePictureDialogState();
}

class ChangeProfilePictureDialogState
    extends State<ChangeProfilePictureDialog> {
  final int numIcons = 9; //NOTE: update when new icons are added

  int? selectedIconIndex;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Change Profile Picture'),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Select a profile picture:'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(numIcons, (index) {
                String iconName = 'icon_$index.png';
                bool isSelected = selectedIconIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIconIndex = index;
                      log('Selected icon index: $selectedIconIndex',
                          name: 'ChangeProfilePictureDialog');
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        isSelected ? Colors.blueAccent : Colors.transparent,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          AssetImage('assets/profile_icons/$iconName'),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary)),
                  onPressed: selectedIconIndex != null
                      ? () {
                          log('Saving selected icon index: $selectedIconIndex',
                              name: 'ChangeProfilePictureDialog');
                          storage.write(
                              key: 'iconImage',
                              value:
                                  'assets/profile_icons/icon_$selectedIconIndex.png');
                          context
                              .read<DatesScrollerBloc>()
                              .add(DatesScrollerReset());
                          context.read<TagsCubit>().resetTags();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (route) => false);
                        }
                      : null,
                  child: const Text('Save',
                      style: TextStyle(
                          fontSize: 20, color: Color.fromRGBO(0, 0, 0, 1))),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
