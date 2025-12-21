import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MyAuthProvider.dart';
import 'admin_manage_users.dart'; // ← import the manage users page

class AdminDashboard extends StatefulWidget {
  static const route = "/admin-dashboard";

  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  // Pages for sidebar
 final List<Widget> pages = [
  const Center(
    child: Text(
      "Welcome Admin",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  ),
  AdminManageUsers(), // ← remove const here
  const Center(
    child: Text(
      "Orders",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  ),
  const Center(
    child: Text(
      "Reports",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  ),
  const Center(
    child: Text(
      "Settings",
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  ),
];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    // Protect admin dashboard
    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/root');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.grey[900],
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildMenuItem(0, "Dashboard", Icons.dashboard),
                _buildMenuItem(1, "Manage Users", Icons.person),
                _buildMenuItem(2, "Orders", Icons.shopping_cart),
                _buildMenuItem(3, "Reports", Icons.bar_chart),
                _buildMenuItem(4, "Settings", Icons.settings),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await auth.logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final bool isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.blue : Colors.white),
      ),
      onTap: () {
        setState(() => selectedIndex = index);
      },
    );
  }
}
