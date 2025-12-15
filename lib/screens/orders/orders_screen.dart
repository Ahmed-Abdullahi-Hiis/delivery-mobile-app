 import 'package:flutter/material.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  static const route = "/orders";
  const OrdersScreen({super.key});

  // sample orders
  final List<Map<String, String>> sampleOrders = const [
    {'id': 'o1', 'title': 'Order #o1', 'status': 'Delivered'},
    {'id': 'o2', 'title': 'Order #o2', 'status': 'On the way'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: sampleOrders.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final o = sampleOrders[i];
          return ListTile(
            title: Text(o['title']!),
            subtitle: Text(o['status']!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: o['id']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
