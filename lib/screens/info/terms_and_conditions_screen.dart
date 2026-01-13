 import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          """
By using Afro Delivery, you agree to follow our rules and policies.

Orders once confirmed cannot be cancelled after preparation starts.

The app is provided as-is for educational purposes.

We may update these terms at any time.
""",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}
