import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MyAuthProvider.dart';
import 'admin_manage_users.dart';
import 'admin_orders.dart';
import 'admin_reports.dart';
import 'admin_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  static const route = "/admin-dashboard";
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  // Firestore references
  final usersRef = FirebaseFirestore.instance.collection('users');
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    // Loading / protection
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });

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
              child: _getPage(),
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
          const Text(
            "Admin Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _menuItem(0, "Dashboard", Icons.dashboard),
          _menuItem(1, "Manage Users", Icons.people),
          _menuItem(2, "Orders", Icons.shopping_cart),
          _menuItem(3, "Reports", Icons.bar_chart),
          _menuItem(4, "Settings", Icons.settings),
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

  // ---------------- Dashboard Page ----------------
  Widget _dashboardPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome Admin 👋",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: usersRef.snapshots(),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final userCount = usersSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: ordersRef.snapshots(),
                builder: (context, ordersSnapshot) {
                  if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final orderCount = ordersSnapshot.data?.docs.length ?? 0;

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _dashboardCard("Users", userCount, Icons.people, Colors.blue),
                      _dashboardCard("Orders", orderCount, Icons.shopping_cart, Colors.green),
                      _dashboardCard("Reports", 0, Icons.bar_chart, Colors.orange), // placeholder
                      _dashboardCard("Settings", 0, Icons.settings, Colors.purple), // placeholder
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

  Widget _dashboardCard(String title, int count, IconData icon, Color color) {
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
