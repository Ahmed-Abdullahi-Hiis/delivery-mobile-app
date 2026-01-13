// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../providers/MyAuthProvider.dart';
// import 'admin_manage_users.dart';
// import 'admin_orders.dart';
// import 'admin_reports.dart';
// import 'admin_settings.dart';

// class AdminDashboard extends StatefulWidget {
//   static const route = "/admin-dashboard";
//   const AdminDashboard({super.key});

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   int selectedIndex = 0;

//   final usersRef = FirebaseFirestore.instance.collection('users');
//   final ordersRef = FirebaseFirestore.instance.collection('orders');

//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<MyAuthProvider>();

//     if (auth.isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (!auth.isAdmin) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, '/login');
//       });
//       return const Scaffold();
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Row(
//         children: [
//           _buildSidebar(auth),
//           Expanded(
//             child: Column(
//               children: [
//                 _buildTopBar(),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: _getPage(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= SIDEBAR =================
//   Widget _buildSidebar(MyAuthProvider auth) {
//     return Container(
//       width: 240,
//       color: const Color(0xFF1F2937),
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             "ADMIN PANEL",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               letterSpacing: 1.2,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 40),

//           _menuItem(0, "Dashboard", Icons.dashboard),
//           _menuItem(1, "Manage Users", Icons.people),
//           _menuItem(2, "Orders", Icons.shopping_bag),
//           _menuItem(3, "Reports", Icons.bar_chart),
//           _menuItem(4, "Settings", Icons.settings),

//           const Spacer(),
//           const Divider(color: Colors.white24),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.redAccent),
//             title: const Text("Logout", style: TextStyle(color: Colors.white)),
//             onTap: () async {
//               await auth.logout();
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 '/login',
//                 (_) => false,
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _menuItem(int index, String title, IconData icon) {
//     final selected = selectedIndex == index;

//     return InkWell(
//       onTap: () => setState(() => selectedIndex = index),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: ListTile(
//           leading: Icon(icon, color: selected ? Colors.blue : Colors.white70),
//           title: Text(
//             title,
//             style: TextStyle(
//               color: selected ? Colors.blue : Colors.white70,
//               fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= TOP BAR =================
//   Widget _buildTopBar() {
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 4),
//         ],
//       ),
//       child: Row(
//         children: const [
//           Text(
//             "Dashboard",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= PAGES =================
//   Widget _getPage() {
//     switch (selectedIndex) {
//       case 0:
//         return _dashboardPage();
//       case 1:
//         return AdminManageUsers();
//       case 2:
//         return AdminOrders();
//       case 3:
//         return AdminReports();
//       case 4:
//         return AdminSettings();
//       default:
//         return const Center(child: Text("Page not found"));
//     }
//   }

//   // ================= DASHBOARD =================
//   Widget _dashboardPage() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Welcome back, Admin 👋",
//           style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           "Overview of your application",
//           style: TextStyle(color: Colors.black54),
//         ),
//         const SizedBox(height: 24),

//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: usersRef.snapshots(),
//             builder: (context, usersSnapshot) {
//               if (!usersSnapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final userCount = usersSnapshot.data!.docs.length;

//               return StreamBuilder<QuerySnapshot>(
//                 stream: ordersRef.snapshots(),
//                 builder: (context, ordersSnapshot) {
//                   if (!ordersSnapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final orderCount = ordersSnapshot.data!.docs.length;

//                   return GridView.count(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     children: [
//                       _statCard("Users", userCount, Icons.people, Colors.blue),
//                       _statCard("Orders", orderCount, Icons.shopping_cart, Colors.green),
//                       _statCard("Reports", 0, Icons.bar_chart, Colors.orange),
//                       _statCard("Settings", 0, Icons.settings, Colors.purple),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _statCard(String title, int value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: color.withOpacity(0.15),
//             child: Icon(icon, color: color),
//           ),
//           const Spacer(),
//           Text(
//             title,
//             style: const TextStyle(color: Colors.black54),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value.toString(),
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







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
            "FOOD ADMIN",
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
      child: const Row(
        children: [
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
    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.snapshots(),
      builder: (context, ordersSnapshot) {
        if (!ordersSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, usersSnapshot) {
            if (!usersSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = ordersSnapshot.data!.docs;
            final usersCount = usersSnapshot.data!.docs.length;

            int totalOrders = orders.length;
            int pending = 0;
            int preparing = 0;
            int delivering = 0;
            int delivered = 0;
            int todayOrders = 0;
            double revenue = 0;

            final today = DateTime.now();

            for (var doc in orders) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final total = data['total'];
              final createdAt = data['createdAt'];

              if (status == 'pending') pending++;
              if (status == 'preparing') preparing++;
              if (status == 'delivering') delivering++;
              if (status == 'delivered') delivered++;

              if (total is num) revenue += total.toDouble();

              if (createdAt is Timestamp) {
                final d = createdAt.toDate();
                if (d.year == today.year &&
                    d.month == today.month &&
                    d.day == today.day) {
                  todayOrders++;
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Food Delivery Overview 🍔",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Business statistics summary",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2, // more height, no overflow
                    children: [
                      _statCard("Users", usersCount.toString(), Icons.people, Colors.blue),
                      _statCard("Total Orders", totalOrders.toString(), Icons.shopping_cart, Colors.teal),
                      _statCard("Today Orders", todayOrders.toString(), Icons.today, Colors.indigo),
                      _statCard("Revenue", "Ksh ${revenue.toStringAsFixed(0)}", Icons.attach_money, Colors.green),

                      _statCard("Pending", pending.toString(), Icons.pending_actions, Colors.orange),
                      _statCard("Preparing", preparing.toString(), Icons.restaurant, Colors.blue),
                      _statCard("Delivering", delivering.toString(), Icons.delivery_dining, Colors.purple),
                      _statCard("Delivered", delivered.toString(), Icons.check_circle, Colors.green),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= STAT CARD (SAFE, NO OVERFLOW) =================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
