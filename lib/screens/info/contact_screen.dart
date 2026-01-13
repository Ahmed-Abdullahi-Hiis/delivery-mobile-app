import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          """
📧 Email: support@afrodelivery.com
📞 Phone: +254 700 000000
📍 Location: Kenya
""",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}
