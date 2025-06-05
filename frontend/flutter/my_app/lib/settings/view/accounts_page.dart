import 'dart:developer';
import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/main/view/dates_wheel_page.dart';
import 'package:date_spark_app/settings/widgets/settings_widgets.dart';
import 'package:date_spark_app/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//TODO: think about adding a password check when updating the users password

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserUpdated) {
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationUserUpdated());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully!')),
                );
                navigator.pop(context);
              }
              if (state is UserUpdateError) {
                if (context.mounted) {
                  log(state.errorMessage.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.errorMessage}')),
                  );
                  navigator.pop(context);
                  if (state.errorMessage.contains('expired')) {
                    context.read<AuthenticationBloc>().add(
                          AuthenticationLogoutPressed(),
                        );
                  }
                }
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                title: const Text(
                  'Change Username',
                  style: TextStyle(fontSize: 22),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangeUsernameDialog();
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 22),
                ),
                trailing: const Icon(Icons.lock),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordDialog();
                    },
                  );
                },
              ),
              const Divider(),
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
                      return BlocProvider.value(
                        value: context.read<UserBloc>(),
                        child: BlocProvider.value(
                          value: context.read<AuthenticationBloc>(),
                          child: const ChangeProfilePictureDialog(),
                        ),
                      );
                    },
                  );
                  log('Selected icon index: $selectedIconIndex',
                      name: 'AccountManagementScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeUsernameDialog extends StatefulWidget {
  const ChangeUsernameDialog({super.key});

  @override
  ChangeUsernameDialogState createState() => ChangeUsernameDialogState();
}

class ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  TextEditingController usernameController = TextEditingController();
  String? usernameError;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text(
        'Change Username',
        style: TextStyle(fontSize: 30),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                '• Must be at least 4 characters long.\n'
                '• Cannot exceed 15 characters.\n'
                '• Must not contain spaces.\n'
                '• Logout to save changes',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              const SizedBox(height: 20),
              UsernameInput(controller: usernameController),
              if (usernameError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    usernameError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                    final isLoading = state is UserLoading;
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              final newUsername = usernameController.text;
                              final validationError =
                                  _validateUsername(newUsername);

                              if (validationError != null) {
                                setState(() {
                                  usernameError = validationError;
                                });
                                return;
                              }
                              context
                                  .read<UserBloc>()
                                  .add(UpdateUserUsername(newUsername));
                            },
                      child: const Text('Save', style: TextStyle(fontSize: 20)),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ChangePasswordDialogState createState() => ChangePasswordDialogState();
}

class ChangePasswordDialogState extends State<ChangePasswordDialog> {
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Change Password'),
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Text(
                  '• Must be at least 8 characters long.\n'
                  '• Cannot exceed 20 characters.\n'
                  '• Must contain at least one uppercase letter.\n'
                  '• Must contain at least one number.\n'
                  '• Must include at least one special character (e.g., !@#\$&*~).\n'
                  '• Passwords must match',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ),
              const SizedBox(height: 20),
              PasswordInput(controller: passwordController1),
              const SizedBox(height: 12),
              PasswordInput(
                controller: passwordController2,
                labelText: 'Verify Password',
              ),
              if (passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                  ),
                  BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                    final isLoading = state is UserLoading;

                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              final newPassword = passwordController1.text;
                              final checkPassword = passwordController2.text;
                              final validationError =
                                  _validatePassword(newPassword, checkPassword);
                              if (validationError != null) {
                                setState(() {
                                  passwordError = validationError;
                                });
                                return;
                              }
                              log("Update Password");
                              context
                                  .read<UserBloc>()
                                  .add(UpdateUserPassword(newPassword));
                            },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
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
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserUpdated) {
          context.read<AuthenticationBloc>().add(AuthenticationUserUpdated());
        }
      },
      child: SimpleDialog(
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
                  BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                    final isLoading = state is UserLoading;
                    return ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary)),
                      onPressed: selectedIconIndex != null && !isLoading
                          ? () {
                              context.read<UserBloc>().add(
                                    UpdateUserProfileIcon(
                                        'assets/profile_icons/icon_$selectedIconIndex.png'),
                                  );
                              Navigator.pop(context, selectedIconIndex);
                            }
                          : null,
                      child: const Text('Save',
                          style: TextStyle(
                              fontSize: 20, color: Color.fromRGBO(0, 0, 0, 1))),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _validatePassword(String password, String checkPassword) {
  if (password.isEmpty) {
    return 'Password cannot be empty';
  }
  if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (password.length > 20) {
    return 'Password must not be more than 20 characters long';
  }
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number';
  }
  if (!password.contains(RegExp(r'[!@#\$&*~-]'))) {
    return 'Password must contain at least one special character (!@#\$&*~)';
  }
  if (password != checkPassword) {
    return "Passwords must match";
  }
  return null;
}

String? _validateUsername(String username) {
  if (username.isEmpty) {
    return 'Username cannot be empty';
  }
  if (username.length < 4) {
    return 'Username must be more than 4 characters long';
  }
  if (username.length > 15) {
    return 'Username must be at most 15 characters long';
  }
  if (username.contains(' ')) {
    return 'Username must not contain spaces';
  }
  return null; // No error
}
