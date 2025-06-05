import 'package:date_spark_app/services/navigation_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  NavigatorState get navigator => navigatorKey.currentState!;

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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
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
            onTap: () {
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
            onTap: () {
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
            onTap: () {
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 22)),
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
            onTap: () {
              navigator.pushNamed('/privacyPolicy');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
