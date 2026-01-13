import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Afro Delivery")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          """
Afro Delivery is a food delivery app built to connect customers with local restaurants.

Our mission is to make food ordering fast, simple, and reliable.

This app was built as a modern delivery system project.
""",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}
