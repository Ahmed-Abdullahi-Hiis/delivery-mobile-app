 import 'package:flutter/material.dart';
import 'track_order_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // replace with real data fetching
    return Scaffold(
      appBar: AppBar(title: Text('Order Details - $orderId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(title: Text('Chicken Burger'), subtitle: Text('x1 - Ksh 450')),
            const ListTile(title: Text('Fries'), subtitle: Text('x1 - Ksh 120')),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: orderId)),
                );
              },
              icon: const Icon(Icons.local_shipping),
              label: const Text('Track Order'),
            ),
          ],
        ),
      ),
    );
  }
}
