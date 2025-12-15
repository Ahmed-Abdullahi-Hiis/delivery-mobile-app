 import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  static const route = "/admin-dashboard";

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: const Center(child: Text("Welcome Admin")),
    );
  }
}
