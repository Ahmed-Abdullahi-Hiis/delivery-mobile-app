import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/MyAuthProvider.dart';
import 'admin_manage_users.dart';
import 'admin_orders.dart';
import 'admin_reports.dart';
import 'admin_settings.dart';

class AdminDashboard extends StatefulWidget {
  static const route = "/admin-dashboard";
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final usersRef = FirebaseFirestore.instance.collection('users');
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Row(
        children: [
          _buildSidebar(auth),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _getPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget _buildSidebar(MyAuthProvider auth) {
    return Container(
      width: 240,
      color: const Color(0xFF1F2937),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "ADMIN PANEL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          _menuItem(0, "Dashboard", Icons.dashboard),
          _menuItem(1, "Manage Users", Icons.people),
          _menuItem(2, "Orders", Icons.shopping_bag),
          _menuItem(3, "Reports", Icons.bar_chart),
          _menuItem(4, "Settings", Icons.settings),

          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: () async {
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem(int index, String title, IconData icon) {
    final selected = selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: selected ? Colors.blue : Colors.white70),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: const [
          Text(
            "Dashboard",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= PAGES =================
  Widget _getPage() {
    switch (selectedIndex) {
      case 0:
        return _dashboardPage();
      case 1:
        return AdminManageUsers();
      case 2:
        return AdminOrders();
      case 3:
        return AdminReports();
      case 4:
        return AdminSettings();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // ================= DASHBOARD =================
  Widget _dashboardPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome back, Admin 👋",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          "Overview of your application",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: usersRef.snapshots(),
            builder: (context, usersSnapshot) {
              if (!usersSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userCount = usersSnapshot.data!.docs.length;

              return StreamBuilder<QuerySnapshot>(
                stream: ordersRef.snapshots(),
                builder: (context, ordersSnapshot) {
                  if (!ordersSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orderCount = ordersSnapshot.data!.docs.length;

                  return GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _statCard("Users", userCount, Icons.people, Colors.blue),
                      _statCard("Orders", orderCount, Icons.shopping_cart, Colors.green),
                      _statCard("Reports", 0, Icons.bar_chart, Colors.orange),
                      _statCard("Settings", 0, Icons.settings, Colors.purple),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
