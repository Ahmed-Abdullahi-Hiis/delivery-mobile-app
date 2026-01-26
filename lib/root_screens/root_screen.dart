

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../admin/admin_dashboard.dart';
import '../screens/home/home_screen.dart';   // ✅ Your shopping home
import '../providers/MyAuthProvider.dart';

class RootScreen extends StatelessWidget {
  static const route = "/root";
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    // Still loading auth state
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Admin goes to admin dashboard
    if (auth.isAdmin) {
      return const AdminDashboard();
    }

    // Normal user goes to HOME (shopping)
    return const HomeScreen(); // ✅ NOT UserDashboard
  }
}
