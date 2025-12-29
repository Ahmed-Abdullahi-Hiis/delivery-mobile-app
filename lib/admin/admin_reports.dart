import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminReports extends StatelessWidget {
  AdminReports({super.key});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getStats() async {
    final usersSnap = await firestore.collection('users').get();
    final ordersSnap = await firestore.collection('orders').get();

    final orders = ordersSnap.docs;
    final pendingOrders =
        orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'pending').length;
    final deliveredOrders =
        orders.where((o) => (o.data() as Map<String, dynamic>)['status'] == 'delivered').length;
    double totalRevenue = 0;
    for (var o in orders) {
      totalRevenue += (o.data() as Map<String, dynamic>)['total'] ?? 0;
    }

    return {
      'users': usersSnap.docs.length,
      'orders': orders.length,
      'pending': pendingOrders,
      'delivered': deliveredOrders,
      'revenue': totalRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Admin Dashboard Reports",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // ---------------- Export PDF Button ----------------
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                  onPressed: () => _exportPDF(data),
                ),
              ),
              const SizedBox(height: 16),

              // ---------------- Summary Cards ----------------
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _summaryCard("Total Users", data['users'], Icons.people, Colors.blue),
                  _summaryCard("Total Orders", data['orders'], Icons.shopping_cart, Colors.orange),
                  _summaryCard("Pending Orders", data['pending'], Icons.pending_actions, Colors.red),
                  _summaryCard("Delivered Orders", data['delivered'], Icons.check_circle, Colors.green),
                  _summaryCard("Total Revenue", data['revenue'].toInt(), Icons.attach_money, Colors.purple),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------- Pie Chart ----------------
              const Text(
                "Order Status Distribution",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: (data['pending'] as int).toDouble(),
                        color: Colors.red,
                        title: 'Pending',
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: (data['delivered'] as int).toDouble(),
                        color: Colors.green,
                        title: 'Delivered',
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Summary Card Widget ----------------
  Widget _summaryCard(String title, int value, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PDF Export ----------------
  void _exportPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Admin Dashboard Reports", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Total Users: ${data['users']}"),
            pw.Text("Total Orders: ${data['orders']}"),
            pw.Text("Pending Orders: ${data['pending']}"),
            pw.Text("Delivered Orders: ${data['delivered']}"),
            pw.Text("Total Revenue: \$${data['revenue'].toStringAsFixed(2)}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
