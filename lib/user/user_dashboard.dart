import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/MyAuthProvider.dart';
import 'user_orders.dart';
import 'user_profile.dart';
import 'user_settings.dart';

class UserDashboard extends StatefulWidget {
  static const route = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int selectedIndex = 0;

  // Firestore references
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    // Loading / protection
    if (auth.isLoading || auth.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          _buildSidebar(auth),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _getPage(auth.user!.uid),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Sidebar ----------------
  Widget _buildSidebar(MyAuthProvider auth) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 0))
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            auth.user?.displayName ?? "User",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.user?.email ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 30),
          _menuItem(0, "Dashboard", Icons.dashboard),
          _menuItem(1, "Orders", Icons.list_alt),
          _menuItem(2, "Profile", Icons.person),
          _menuItem(3, "Settings", Icons.settings),
          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------- Menu Item ----------------
  Widget _menuItem(int index, String title, IconData icon) {
    final bool selected = selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      hoverColor: Colors.grey.shade800,
      child: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              )
            : null,
        child: ListTile(
          leading: Icon(icon, color: selected ? Colors.blue : Colors.white),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.white,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Pages ----------------
  Widget _getPage(String uid) {
    switch (selectedIndex) {
      case 0:
        return _dashboardPage(uid);
      case 1:
        return UserOrders(userId: uid);
      case 2:
        return const UserProfile();
      case 3:
        return const UserSettings();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // ---------------- Dashboard ----------------
  Widget _dashboardPage(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.where('userId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders yet"));
        }

        final orders = snapshot.data!.docs;
        final pending = orders.where((o) =>
            (o.data() as Map<String, dynamic>)['status'] == 'pending').length;
        final delivered = orders.where((o) =>
            (o.data() as Map<String, dynamic>)['status'] == 'delivered').length;

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _card("Total Orders", orders.length, Icons.list_alt, Colors.blue),
            _card("Pending Orders", pending, Icons.pending_actions, Colors.orange),
            _card("Delivered Orders", delivered, Icons.check_circle, Colors.green),
          ],
        );
      },
    );
  }

  Widget _card(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}



