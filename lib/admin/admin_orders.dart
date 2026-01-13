

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// // ⚠️ Adjust this import path to your project structure
// import '../../screens/orders/order_details_screen.dart';

// class AdminOrders extends StatelessWidget {
//   AdminOrders({super.key});

//   final CollectionReference ordersRef =
//       FirebaseFirestore.instance.collection('orders');

//   // Status colors
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'preparing':
//         return Colors.blue;
//       case 'delivering':
//         return Colors.purple;
//       case 'delivered':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   // Pretty labels
//   String _prettyStatus(String status) {
//     switch (status) {
//       case 'pending':
//         return 'Pending';
//       case 'preparing':
//         return 'Preparing';
//       case 'delivering':
//         return 'Delivering';
//       case 'delivered':
//         return 'Delivered';
//       default:
//         return status;
//     }
//   }

//   final List<String> _statuses = [
//     'pending',
//     'preparing',
//     'delivering',
//     'delivered',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Orders Management",
//           style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           "View and update customer delivery orders",
//           style: TextStyle(color: Colors.black54),
//         ),
//         const SizedBox(height: 24),

//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: ordersRef
//                 .orderBy('createdAt', descending: true)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final orders = snapshot.data!.docs;

//               if (orders.isEmpty) {
//                 return const Center(child: Text("No orders found."));
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 itemCount: orders.length,
//                 itemBuilder: (context, index) {
//                   final doc = orders[index];
//                   final data = doc.data() as Map<String, dynamic>;

//                   final status = data['status'] ?? 'pending';
//                   final total = data['total'] ?? 0;
//                   final userEmail = data['userEmail'] ?? 'Unknown';
//                   final phone = data['phone'] ?? '';
//                   final address = data['address'] ?? '';

//                   return InkWell(
//                     borderRadius: BorderRadius.circular(16),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               OrderDetailsScreen(orderId: doc.id),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: const [
//                           BoxShadow(color: Colors.black12, blurRadius: 6),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // Icon
//                           CircleAvatar(
//                             radius: 22,
//                             backgroundColor:
//                                 _statusColor(status).withOpacity(0.15),
//                             child: Icon(
//                               Icons.shopping_bag,
//                               color: _statusColor(status),
//                             ),
//                           ),

//                           const SizedBox(width: 16),

//                           // Order info
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   userEmail,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "Total: Ksh $total",
//                                   style: const TextStyle(
//                                       color: Colors.black54),
//                                 ),
//                                 if (phone.isNotEmpty)
//                                   Text(
//                                     "Phone: $phone",
//                                     style: const TextStyle(
//                                         color: Colors.black45, fontSize: 12),
//                                   ),
//                                 if (address.isNotEmpty)
//                                   Text(
//                                     "Address: $address",
//                                     style: const TextStyle(
//                                         color: Colors.black45, fontSize: 12),
//                                   ),
//                               ],
//                             ),
//                           ),

//                           // Status + Dropdown
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       _statusColor(status).withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   _prettyStatus(status).toUpperCase(),
//                                   style: TextStyle(
//                                     color: _statusColor(status),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),

//                               DropdownButtonHideUnderline(
//                                 child: DropdownButton<String>(
//                                   value: status,
//                                   items: _statuses
//                                       .map(
//                                         (s) => DropdownMenuItem(
//                                           value: s,
//                                           child: Text(_prettyStatus(s)),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (newStatus) async {
//                                     if (newStatus == null) return;

//                                     await ordersRef
//                                         .doc(doc.id)
//                                         .update({'status': newStatus});

//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'Order updated to ${_prettyStatus(newStatus)}',
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }










import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Adjust this import path to your project structure
import '../../screens/orders/order_details_screen.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  final CollectionReference ordersRef =
      FirebaseFirestore.instance.collection('orders');

  String selectedFilter = 'all';

  final List<String> _statuses = [
    'pending',
    'preparing',
    'delivering',
    'delivered',
  ];

  // ================= HELPERS =================
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'delivering':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _prettyStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'delivering':
        return 'Delivering';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= HEADER =================
        const Text(
          "Orders Management",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          "View and update customer delivery orders",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),

        // ================= FILTERS =================
        Wrap(
          spacing: 10,
          children: [
            _filterChip("All", "all"),
            _filterChip("Pending", "pending"),
            _filterChip("Preparing", "preparing"),
            _filterChip("Delivering", "delivering"),
            _filterChip("Delivered", "delivered"),
          ],
        ),

        const SizedBox(height: 20),

        // ================= LIST =================
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: ordersRef
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allOrders = snapshot.data!.docs;

              // Apply filter
              final orders = selectedFilter == 'all'
                  ? allOrders
                  : allOrders.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == selectedFilter;
                    }).toList();

              if (orders.isEmpty) {
                return const Center(child: Text("No orders found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final doc = orders[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final status = data['status'] ?? 'pending';
                  final total = data['total'] ?? 0;
                  final userEmail = data['userEmail'] ?? 'Unknown';
                  final phone = data['phone'] ?? '';
                  final address = data['address'] ?? '';

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsScreen(orderId: doc.id),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ================= ICON =================
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                _statusColor(status).withOpacity(0.15),
                            child: Icon(
                              Icons.shopping_bag,
                              color: _statusColor(status),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ================= INFO =================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Total: Ksh $total",
                                  style: const TextStyle(
                                      color: Colors.black54),
                                ),
                                if (phone.isNotEmpty)
                                  Text(
                                    "Phone: $phone",
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12),
                                  ),
                                if (address.isNotEmpty)
                                  Text(
                                    "Address: $address",
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),

                          // ================= STATUS + ACTION =================
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _prettyStatus(status).toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: status,
                                  items: _statuses
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(_prettyStatus(s)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (newStatus) async {
                                    if (newStatus == null) return;

                                    await ordersRef
                                        .doc(doc.id)
                                        .update({'status': newStatus});

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Order updated to ${_prettyStatus(newStatus)}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= FILTER CHIP =================
  Widget _filterChip(String label, String value) {
    final selected = selectedFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => selectedFilter = value);
      },
    );
  }
}
