// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserOrders extends StatelessWidget {
//   final String userId;
//   const UserOrders({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     final ordersRef = FirebaseFirestore.instance.collection('orders');

//     return StreamBuilder<QuerySnapshot>(
//       stream: ordersRef
//           .where('userId', isEqualTo: userId)
//           .snapshots(), // ❌ removed orderBy to avoid index issue
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Text("Error: ${snapshot.error}"),
//           );
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text("No orders found"));
//         }

//         final orders = snapshot.data!.docs;

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: orders.length,
//           itemBuilder: (context, index) {
//             final data = orders[index].data() as Map<String, dynamic>;

//             final total = data['total'] ?? 0;
//             final status = data['status'] ?? 'pending';

//             return Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               elevation: 2,
//               child: ListTile(
//                 title: Text("Order ID: ${orders[index].id}"),
//                 subtitle: Text("Total: \$${total.toString()}"),
//                 trailing: Text(
//                   status.toUpperCase(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: status == 'delivered'
//                         ? Colors.green
//                         : status == 'pending'
//                             ? Colors.orange
//                             : Colors.blue,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }










import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for formatting dates and numbers

class UserOrders extends StatelessWidget {
  final String userId;
  const UserOrders({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No orders found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            final total = data['total'] ?? 0.0;
            final status = data['status'] ?? 'pending';
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('dd MMM yyyy, hh:mm a')
                    .format(timestamp.toDate())
                : "No date";

            Color statusColor;
            switch (status) {
              case 'delivered':
                statusColor = Colors.green;
                break;
              case 'pending':
                statusColor = Colors.orange;
                break;
              default:
                statusColor = Colors.blue;
            }

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text("Order ID: ${orders[index].id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total: \$${total.toStringAsFixed(2)}"),
                    const SizedBox(height: 4),
                    Text("Date: $date"),
                  ],
                ),
                trailing: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                onTap: () {
                  // Optional: navigate to order details page
                },
              ),
            );
          },
        );
      },
    );
  }
}
