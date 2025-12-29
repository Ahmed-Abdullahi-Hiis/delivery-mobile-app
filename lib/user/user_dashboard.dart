import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/MyAuthProvider.dart';
import 'user_orders.dart';
import 'user_profile.dart';
import 'user_settings.dart';
// import 'user_report.dart'; // new report page

class UserDashboard extends StatefulWidget {
  static const route = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int selectedIndex = 0;
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    if (auth.isLoading || auth.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: Text(auth.user?.displayName ?? "User Dashboard"))
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(auth)) : null,
      body: isMobile
          ? _getPage(auth.user!.uid)
          : Row(
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
      color: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                auth.user?.displayName != null
                    ? auth.user!.displayName![0].toUpperCase()
                    : "U",
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.user?.displayName ?? "User",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(auth.user?.email ?? "",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _menuItem(0, "Dashboard", Icons.dashboard),
                    _menuItem(1, "Orders", Icons.list_alt),
                    _menuItem(2, "Profile", Icons.person),
                    _menuItem(3, "Settings", Icons.settings),
                    // _menuItem(4, "Reports", Icons.receipt_long), // new menu item
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () async {
                await auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- Menu Item ----------------
  Widget _menuItem(int index, String title, IconData icon) {
    final bool selected = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);
        if (MediaQuery.of(context).size.width < 800) Navigator.pop(context);
      },
      hoverColor: Colors.grey.shade800,
      child: Container(
        decoration: selected
            ? BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(16)),
              )
            : null,
        child: ListTile(
          leading: Icon(icon, color: selected ? Colors.blue : Colors.white),
          title: Text(title,
              style: TextStyle(
                  color: selected ? Colors.blue : Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
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

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders yet"));
        }

        final orders = snapshot.data!.docs;
        final pending = orders.where(
            (o) => (o.data() as Map<String, dynamic>)['status'] == 'pending');
        final delivered = orders.where(
            (o) => (o.data() as Map<String, dynamic>)['status'] == 'delivered');

        return LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : constraints.maxWidth > 800
                  ? 3
                  : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _card(
                      "Total Orders", orders.length, Icons.list_alt, Colors.blue);
                case 1:
                  return _card("Pending Orders", pending.length,
                      Icons.pending_actions, Colors.orange);
                case 2:
                  return _card("Delivered Orders", delivered.length,
                      Icons.check_circle, Colors.green);
                default:
                  return const SizedBox.shrink();
              }
            },
          );
        });
      },
    );
  }

  Widget _card(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {}, // optional: navigate to details
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(title,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(count.toString(),
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
