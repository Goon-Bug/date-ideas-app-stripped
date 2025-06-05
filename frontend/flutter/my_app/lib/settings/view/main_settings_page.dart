import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoggingOut = false;
  NavigatorState get navigator => navigatorKey.currentState!;

  void _onLogoutPressed() {
    setState(() {
      _isLoggingOut = true;
    });

    context.read<AuthenticationBloc>().add(AuthenticationLogoutPressed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 26),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoggingOut
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isLoggingOut,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                size: 34,
              ),
              title: const Text(
                'Account',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: const Text(
                'Manage your account settings',
                style: TextStyle(fontSize: 15),
              ),
              onTap: _isLoggingOut
                  ? null
                  : () {
                      navigator.pushNamed('/accountManagement');
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.color_lens,
                size: 34,
              ),
              title: const Text(
                'Change Theme',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: const Text(
                'Change the color scheme',
                style: TextStyle(fontSize: 15),
              ),
              onTap: _isLoggingOut
                  ? null
                  : () {
                      navigator.pushNamed('/changeTheme');
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.help_outline,
                size: 34,
              ),
              title: const Text(
                'Help & Support',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: const Text(
                'Get help and support',
                style: TextStyle(fontSize: 15),
              ),
              onTap: _isLoggingOut
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Help and Support',
                              style: TextStyle(fontSize: 22),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'If you have any queries please email me at goon-bug@hotmail.com',
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 22)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.article_outlined,
                size: 34,
              ),
              title: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: const Text(
                'Read the privacy policy',
                style: TextStyle(fontSize: 15),
              ),
              onTap: _isLoggingOut
                  ? null
                  : () {
                      navigator.pushNamed('/privacyPolicy');
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                size: 34,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(fontSize: 22),
              ),
              subtitle: const Text(
                'Logout from the app',
                style: TextStyle(fontSize: 15),
              ),
              onTap: _isLoggingOut
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Logout',
                              style: TextStyle(fontSize: 28),
                            ),
                            content: const Text(
                              'Are you sure you want to log out?',
                              style: TextStyle(fontSize: 18),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _onLogoutPressed();
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
