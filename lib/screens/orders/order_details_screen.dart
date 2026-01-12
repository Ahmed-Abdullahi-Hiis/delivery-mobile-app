//  import 'package:flutter/material.dart';
// import 'track_order_screen.dart';

// class OrderDetailsScreen extends StatelessWidget {
//   final String orderId;
//   const OrderDetailsScreen({super.key, required this.orderId});

//   @override
//   Widget build(BuildContext context) {
//     // replace with real data fetching
//     return Scaffold(
//       appBar: AppBar(title: Text('Order Details - $orderId')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             const ListTile(title: Text('Chicken Burger'), subtitle: Text('x1 - Ksh 450')),
//             const ListTile(title: Text('Fries'), subtitle: Text('x1 - Ksh 120')),
//             const Spacer(),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: orderId)),
//                 );
//               },
//               icon: const Icon(Icons.local_shipping),
//               label: const Text('Track Order'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          final total = data['total'] ?? 0;
          final status = data['status'] ?? 'pending';
          final address = data['address'] ?? '';
          final phone = data['phone'] ?? '';
          final paymentMethod = data['paymentMethod'] ?? 'cash';
          final paid = data['paid'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Status", status.toUpperCase()),
                _infoRow("Total", "Ksh $total"),
                _infoRow("Payment", paymentMethod),
                _infoRow("Paid", paid ? "Yes" : "No"),
                _infoRow("Phone", phone),
                _infoRow("Address", address),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                const Text(
                  "Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Card(
                        child: ListTile(
                          leading: item['image'] != null
                              ? Image.asset(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood),
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(
                              "Qty: ${item['qty']}  •  Ksh ${item['price']}"),
                          trailing: Text(
                            "Ksh ${item['price'] * item['qty']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
