//  import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PlaceOrderScreen extends StatefulWidget {
//   const PlaceOrderScreen({super.key});

//   @override
//   State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
// }

// class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
//   final _totalController = TextEditingController();
//   bool _loading = false;

//   @override
//   void dispose() {
//     _totalController.dispose();
//     super.dispose();
//   }

//   Future<void> _placeOrder() async {
//     final text = _totalController.text.trim();
//     final total = double.tryParse(text);

//     if (total == null || total <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid amount")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser!;
//       final doc = await FirebaseFirestore.instance.collection('orders').add({
//         'userId': user.uid,
//         'userEmail': user.email,
//         'total': total,
//         'status': 'pending',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       Navigator.pushReplacementNamed(
//         context,
//         '/order-success',
//         arguments: doc.id,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to place order: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Place Order")),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Order Total",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _totalController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 hintText: "Enter total amount",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _placeOrder,
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Confirm Order"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/cart_provider.dart';

class PlaceOrderScreen extends StatefulWidget {
  static const route = "/place-order";
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  bool _loading = false;

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to place an order")),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final doc = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email,
        'items': cart.items.values.map((e) => {
          'id': e.food.id,
          'name': e.food.name,
          'price': e.food.price,
          'qty': e.quantity,
          'image': e.food.image,
        }).toList(),
        'total': cart.totalPrice,
        'status': 'pending',
        'paymentMethod': 'cash',
        'paid': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      cart.clearCart();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/order-success',
        arguments: doc.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Order")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: cart.items.values.map((item) {
                  return ListTile(
                    title: Text(item.food.name),
                    subtitle: Text("x${item.quantity}"),
                    trailing: Text(
                      "Ksh ${(item.food.price * item.quantity).toStringAsFixed(0)}",
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Ksh ${cart.totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Place Order (Pay on Delivery)",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
