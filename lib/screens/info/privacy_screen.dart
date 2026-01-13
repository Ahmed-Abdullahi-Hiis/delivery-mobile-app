import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          """
We respect your privacy.

Your data is only used for order processing and account management.

We do not sell your personal information.
""",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}
