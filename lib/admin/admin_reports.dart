// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class AdminReports extends StatelessWidget {
//   AdminReports({super.key});

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // ================= FETCH STATS =================
//   Future<Map<String, dynamic>> getStats() async {
//     final usersSnap = await firestore.collection('users').get();
//     final ordersSnap = await firestore.collection('orders').get();

//     int pendingOrders = 0;
//     int deliveredOrders = 0;
//     double totalRevenue = 0;

//     for (var doc in ordersSnap.docs) {
//       final data = doc.data();

//       // Status (safe fallback)
//       final status = data['status'] ?? 'pending';
//       if (status == 'pending') pendingOrders++;
//       if (status == 'delivered') deliveredOrders++;

//       // Revenue (safe numeric check)
//       final total = data['total'];
//       if (total is num) {
//         totalRevenue += total.toDouble();
//       }
//     }

//     return {
//       'users': usersSnap.docs.length,
//       'orders': ordersSnap.docs.length,
//       'pending': pendingOrders,
//       'delivered': deliveredOrders,
//       'revenue': totalRevenue,
//     };
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: getStats(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData) {
//           return const Center(child: Text("Failed to load reports"));
//         }

//         final data = snapshot.data!;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Admin Dashboard Reports",
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Overview of users, orders, and revenue",
//                 style: TextStyle(color: Colors.black54),
//               ),
//               const SizedBox(height: 20),

//               // ================= EXPORT PDF =================
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.picture_as_pdf),
//                   label: const Text("Export PDF"),
//                   onPressed: () => _exportPDF(data),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // ================= SUMMARY CARDS =================
//               Wrap(
//                 spacing: 16,
//                 runSpacing: 16,
//                 children: [
//                   _summaryCard("Total Users", data['users'], Icons.people, Colors.blue),
//                   _summaryCard("Total Orders", data['orders'], Icons.shopping_cart, Colors.orange),
//                   _summaryCard("Pending Orders", data['pending'], Icons.pending_actions, Colors.red),
//                   _summaryCard("Delivered Orders", data['delivered'], Icons.check_circle, Colors.green),
//                   _summaryCard(
//                     "Total Revenue",
//                     data['revenue'].toInt(),
//                     Icons.attach_money,
//                     Colors.purple,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 32),

//               // ================= PIE CHART =================
//               const Text(
//                 "Order Status Distribution",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),

//               SizedBox(
//                 height: 220,
//                 child: PieChart(
//                   PieChartData(
//                     sectionsSpace: 4,
//                     centerSpaceRadius: 45,
//                     sections: [
//                       PieChartSectionData(
//                         value: (data['pending'] as int).toDouble(),
//                         color: Colors.orange,
//                         title: 'Pending',
//                         radius: 60,
//                         titleStyle: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       PieChartSectionData(
//                         value: (data['delivered'] as int).toDouble(),
//                         color: Colors.green,
//                         title: 'Delivered',
//                         radius: 60,
//                         titleStyle: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ================= SUMMARY CARD =================
//   Widget _summaryCard(String title, int value, IconData icon, Color color) {
//     return SizedBox(
//       width: 170,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Icon(icon, size: 36, color: color),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 value.toString(),
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= PDF EXPORT =================
//   void _exportPDF(Map<String, dynamic> data) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(
//               "Admin Dashboard Reports",
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//             pw.SizedBox(height: 20),
//             pw.Text("Total Users: ${data['users']}"),
//             pw.Text("Total Orders: ${data['orders']}"),
//             pw.Text("Pending Orders: ${data['pending']}"),
//             pw.Text("Delivered Orders: ${data['delivered']}"),
//             pw.Text(
//               "Total Revenue: \$${data['revenue'].toStringAsFixed(2)}",
//             ),
//           ],
//         ),
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (format) async => pdf.save(),
//     );
//   }
// }









import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminReports extends StatelessWidget {
  AdminReports({super.key});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ================= FETCH STATS =================
  Future<Map<String, dynamic>> getStats() async {
    final usersSnap = await firestore.collection('users').get();
    final ordersSnap = await firestore.collection('orders').get();

    int pending = 0;
    int preparing = 0;
    int delivering = 0;
    int delivered = 0;
    double totalRevenue = 0;

    for (var doc in ordersSnap.docs) {
      final data = doc.data();

      final status = data['status'] ?? 'pending';
      if (status == 'pending') pending++;
      if (status == 'preparing') preparing++;
      if (status == 'delivering') delivering++;
      if (status == 'delivered') delivered++;

      final total = data['total'];
      if (total is num) {
        totalRevenue += total.toDouble();
      }
    }

    return {
      'users': usersSnap.docs.length,
      'orders': ordersSnap.docs.length,
      'pending': pending,
      'preparing': preparing,
      'delivering': delivering,
      'delivered': delivered,
      'revenue': totalRevenue,
    };
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Failed to load reports"));
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              const Text(
                "Reports & Analytics",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Business performance overview",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // ================= EXPORT =================
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                  onPressed: () => _exportPDF(data),
                ),
              ),

              const SizedBox(height: 24),

              // ================= SUMMARY =================
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _summaryCard("Users", data['users'], Icons.people, Colors.blue),
                  _summaryCard("Orders", data['orders'], Icons.shopping_cart, Colors.teal),
                  _summaryCard("Revenue", data['revenue'].toInt(), Icons.attach_money, Colors.green),
                  _summaryCard("Delivered", data['delivered'], Icons.check_circle, Colors.green),
                  _summaryCard("Pending", data['pending'], Icons.pending_actions, Colors.orange),
                  _summaryCard("Preparing", data['preparing'], Icons.restaurant, Colors.blue),
                  _summaryCard("Delivering", data['delivering'], Icons.delivery_dining, Colors.purple),
                ],
              ),

              const SizedBox(height: 36),

              // ================= CHART =================
              const Text(
                "Order Status Distribution",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 260,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 45,
                    sections: [
                      _pieSection("Pending", data['pending'], Colors.orange),
                      _pieSection("Preparing", data['preparing'], Colors.blue),
                      _pieSection("Delivering", data['delivering'], Colors.purple),
                      _pieSection("Delivered", data['delivered'], Colors.green),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= PIE SECTION =================
  PieChartSectionData _pieSection(String title, int value, Color color) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: "$title\n$value",
      radius: 60,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard(String title, int value, IconData icon, Color color) {
    return SizedBox(
      width: 170,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PDF EXPORT =================
  void _exportPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Admin Dashboard Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Users: ${data['users']}"),
            pw.Text("Orders: ${data['orders']}"),
            pw.Text("Pending: ${data['pending']}"),
            pw.Text("Preparing: ${data['preparing']}"),
            pw.Text("Delivering: ${data['delivering']}"),
            pw.Text("Delivered: ${data['delivered']}"),
            pw.Text("Revenue: Ksh ${data['revenue'].toStringAsFixed(2)}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
