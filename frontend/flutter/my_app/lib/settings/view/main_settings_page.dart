import 'dart:developer';

import 'package:date_spark_app/services/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              Navigator.pushNamed(context, '/accountManagement');
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
              Navigator.pushNamed(context, '/changeTheme');
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
                          'If you have any queries or would like to submit any feedback or feature requests then please email me at goon-bug@hotmail.com',
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
              Navigator.pushNamed(context, '/privacyPolicy');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.assignment_add,
              size: 34,
            ),
            title: const Text(
              'Request a City',
              style: TextStyle(fontSize: 22),
            ),
            subtitle: const Text(
              'Request a new city to be added',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              showCityInputDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showCityInputDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                maxLength: 26,
                decoration: const InputDecoration(
                  labelText: 'City Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'City name is required';
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
                    return 'Only letters and spaces allowed';
                  }
                  if (trimmed.length > 26) return 'Max 26 characters allowed';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            Text('The Cities with the most requests will be added first.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                final city = controller.text.trim();

                AdManager().showInterstitialAd(
                  context: context,
                  onAdClosed: () {
                    submitCityToSheet(city);
                    log('City submitted: $city', name: 'showCityInputDialog');
                    Navigator.of(context).pop(city);
                  },
                );
              }
            },
            child: Text(
              'Request',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<bool> submitCityToSheet(String city) async {
  const String url =
      'https://script.google.com/macros/s/AKfycbzSK7QFyqKNiSGFCiZl_KO60rwQOQ5U7i1RD2WIhRwUXGt5O5XQfGbC2FTWwdogjkEe/exec';

  final formattedCity = toTitleCase(city);
  try {
    final request = http.Request('POST', Uri.parse(url))
      ..bodyFields = {'city': formattedCity};

    final streamedResponse = await request.send();

    // Check for redirect (302)
    if (streamedResponse.statusCode == 302) {
      final redirectedUrl = streamedResponse.headers['location'];
      if (redirectedUrl != null) {
        final redirectedResponse = await http.get(Uri.parse(redirectedUrl));
        log('Redirected response: ${redirectedResponse.body}');
        return redirectedResponse.body.contains('"success": true');
      }
    }

    // Otherwise read the original response
    final responseBody = await streamedResponse.stream.bytesToString();
    log('Response: $responseBody');
    return responseBody.contains('"success": true');
  } catch (e) {
    log('Error submitting city: $e');
    return false;
  }
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) => word.isEmpty
          ? ''
          : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
