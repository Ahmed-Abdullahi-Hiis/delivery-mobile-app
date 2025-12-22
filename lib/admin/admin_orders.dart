 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrders extends StatelessWidget {
  AdminOrders({super.key});

  final CollectionReference ordersRef =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data() as Map<String, dynamic>;

            final status = data['status'] ?? 'pending';
            final total = data['total'] ?? 0;
            final userEmail = data['userEmail'] ?? 'Unknown';

            return Card(
              child: ListTile(
                title: Text("Order by $userEmail"),
                subtitle: Text("Total: \$${total.toString()}"),
                trailing: DropdownButton<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(
                        value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'accepted', child: Text('Accepted')),
                    DropdownMenuItem(
                        value: 'delivered', child: Text('Delivered')),
                  ],
                  onChanged: (newStatus) async {
                    await ordersRef
                        .doc(doc.id)
                        .update({'status': newStatus});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order updated to $newStatus')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
