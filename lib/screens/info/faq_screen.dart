import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          """
Q: How do I order food?
A: Choose a restaurant, add items to cart, and checkout.

Q: How do I pay?
A: You can pay with cash on delivery.

Q: How long does delivery take?
A: Usually 20–45 minutes.
""",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}
