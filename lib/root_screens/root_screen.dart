import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your dashboards
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart'; // <-- Make sure this path points to user_dashboard.dart

import '../providers/MyAuthProvider.dart';

class RootScreen extends StatelessWidget {
  static const route = "/root";
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    // Show loading spinner while user info is being fetched
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If the user is an admin, go to AdminDashboard
    if (auth.isAdmin) {
      return AdminDashboard(); // No const
    }

    // Otherwise, go to UserDashboard
    return UserDashboard(); // No const
  }
}
