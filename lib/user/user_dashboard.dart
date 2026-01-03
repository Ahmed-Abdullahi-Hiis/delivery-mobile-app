import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/MyAuthProvider.dart';
import 'user_orders.dart';
import 'user_profile.dart';
import 'user_settings.dart';
// import '../auth/login_screen.dart';
import '../../screens/auth/login_screen.dart'; // ✅ FIXED

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Row(
        children: [
          _sidebar(auth),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(auth),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _page(auth.user!.uid),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------ TOP BAR ------------------
  Widget _topBar(MyAuthProvider auth) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _title(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            auth.user!.email ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _title() {
    switch (selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Orders';
      case 2:
        return 'Profile';
      case 3:
        return 'Settings';
      default:
        return '';
    }
  }

  /// ------------------ PAGES ------------------
  Widget _page(String uid) {
    switch (selectedIndex) {
      case 0:
        return _dashboard(uid);
      case 1:
        return UserOrders(userId: uid);
      case 2:
        return const UserProfile();
      case 3:
        return const UserSettings();
      default:
        return _dashboard(uid);
    }
  }

  Widget _dashboard(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.where('userId', isEqualTo: uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "You haven’t placed any orders yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final orders = snap.data!.docs;
        final pending =
            orders.where((o) => (o.data() as Map)['status'] == 'pending').length;
        final delivered =
            orders.where((o) => (o.data() as Map)['status'] == 'delivered')
                .length;

        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _card("Total Orders", orders.length, Icons.shopping_bag,
                Colors.blue),
            _card("Pending", pending, Icons.pending, Colors.orange),
            _card("Delivered", delivered, Icons.check_circle, Colors.green),
          ],
        );
      },
    );
  }

  Widget _card(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 26, color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------ SIDEBAR ------------------
  Widget _sidebar(MyAuthProvider auth) {
    return Container(
      width: 230,
      color: Colors.grey.shade900,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.person, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            auth.user!.email ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _item(0, "Dashboard", Icons.dashboard),
          _item(1, "Orders", Icons.list_alt),
          _item(2, "Profile", Icons.person),
          _item(3, "Settings", Icons.settings),

          const Spacer(),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(
                context,
                LoginScreen.route,
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _item(int index, String title, IconData icon) {
    final selected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: selected ? Colors.blue : Colors.white),
      ),
      selected: selected,
      onTap: () => setState(() => selectedIndex = index),
    );
  }
}
