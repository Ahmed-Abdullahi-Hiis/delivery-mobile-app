 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  static const route = "/orders";

  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                "No orders yet 🍽️",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(
                      "KES ${order.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${order.items.length} items • ${order.date.toLocal().toString().split('.')[0]}",
                    ),
                    trailing: Chip(
                      label: Text(order.status),
                      backgroundColor: Colors.green.withOpacity(0.15),
                      labelStyle:
                          const TextStyle(color: Colors.green),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
