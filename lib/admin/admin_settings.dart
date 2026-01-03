import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSettings extends StatelessWidget {
  AdminSettings({super.key});

  final DocumentReference settingsRef =
      FirebaseFirestore.instance.collection('settings').doc('app');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: settingsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        final maintenance = data['maintenance'] ?? false;
        final acceptOrders = data['acceptOrders'] ?? true;
        final cashOnDelivery = data['cashOnDelivery'] ?? true;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "App Settings",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Control how the delivery app behaves",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // ================= MAINTENANCE =================
              _settingsCard(
                title: "Maintenance Mode",
                subtitle:
                    "Disable app access for all normal users",
                child: SwitchListTile(
                  value: maintenance,
                  onChanged: (value) {
                    settingsRef.set(
                      {'maintenance': value},
                      SetOptions(merge: true),
                    );
                  },
                  title: const Text("Enable Maintenance"),
                ),
              ),

              const SizedBox(height: 16),

              // ================= ACCEPT ORDERS =================
              _settingsCard(
                title: "Accept New Orders",
                subtitle:
                    "Allow users to place new delivery orders",
                child: SwitchListTile(
                  value: acceptOrders,
                  onChanged: (value) {
                    settingsRef.set(
                      {'acceptOrders': value},
                      SetOptions(merge: true),
                    );
                  },
                  title: const Text("Accept Orders"),
                ),
              ),

              const SizedBox(height: 16),

              // ================= PAYMENT =================
              _settingsCard(
                title: "Cash on Delivery",
                subtitle:
                    "Allow users to pay with cash upon delivery",
                child: SwitchListTile(
                  value: cashOnDelivery,
                  onChanged: (value) {
                    settingsRef.set(
                      {'cashOnDelivery': value},
                      SetOptions(merge: true),
                    );
                  },
                  title: const Text("Enable Cash on Delivery"),
                ),
              ),

              const SizedBox(height: 24),

              // ================= STATUS PREVIEW =================
              Card(
                color: Colors.grey.shade100,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current App Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _statusRow(
                        "Maintenance",
                        maintenance ? "ON" : "OFF",
                        maintenance ? Colors.red : Colors.green,
                      ),
                      _statusRow(
                        "Accepting Orders",
                        acceptOrders ? "YES" : "NO",
                        acceptOrders ? Colors.green : Colors.red,
                      ),
                      _statusRow(
                        "Cash on Delivery",
                        cashOnDelivery ? "ENABLED" : "DISABLED",
                        cashOnDelivery ? Colors.green : Colors.red,
                      ),
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

  // ================= HELPERS =================
  Widget _settingsCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
