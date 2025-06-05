import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _privacyPolicy = "Loading...";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the privacy policy when the page is revisited
    if (_isLoading) {
      _fetchPrivacyPolicy();
    }
  }

  Future<void> _fetchPrivacyPolicy() async {
    final url = Uri.parse(
        'https://raw.githubusercontent.com/Goon-Bug/datespark-privacy-policy/refs/heads/main/privacy-policy');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _privacyPolicy = response.body;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        _showError();
      }
    } catch (e) {
      _showError();
    }
  }

  void _showError() {
    setState(() {
      _privacyPolicy = "Failed to load privacy policy. Please try again later.";
      _isLoading = false;
      _hasError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _hasError
                  ? Text(
                      _privacyPolicy,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    )
                  : Markdown(
                      data: _privacyPolicy,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ).copyWith(
                        p: TextStyle(fontFamily: 'default'),
                        h1: TextStyle(fontFamily: 'default', fontSize: 26),
                        h2: TextStyle(fontFamily: 'default', fontSize: 22),
                        h3: TextStyle(fontFamily: 'default', fontSize: 20),
                        h4: TextStyle(fontFamily: 'default', fontSize: 18),
                        h5: TextStyle(fontFamily: 'default', fontSize: 16),
                        h6: TextStyle(fontFamily: 'default', fontSize: 14),
                      ),
                    ),
            ),
    );
  }
}
