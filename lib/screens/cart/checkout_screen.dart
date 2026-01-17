





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../providers/cart_provider.dart';
// import '../../providers/MyAuthProvider.dart';

// class CheckoutScreen extends StatefulWidget {
//   final double totalAmount;
//   final List<String> productNames;

//   const CheckoutScreen({
//     super.key,
//     required this.totalAmount,
//     required this.productNames,
//   });

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   bool _loading = false;

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _placeOrder() async {
//     final address = _addressController.text.trim();
//     final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

//     if (address.isEmpty || phone.isEmpty) {
//       _showError('Please fill all fields');
//       return;
//     }

//     if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
//       _showError('Phone must start with 254 and have 12 digits');
//       return;
//     }

//     final cart = context.read<CartProvider>();
//     final auth = context.read<MyAuthProvider>();

//     if (cart.items.isEmpty) {
//       _showError("Cart is empty");
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       await FirebaseFirestore.instance.collection('orders').add({
//         'userId': auth.user?.uid,
//         'userEmail': auth.user?.email,
//         'address': address,
//         'phone': phone,
//         'items': cart.items.values.map((e) => {
//           'id': e.food.id,
//           'name': e.food.name,
//           'price': e.food.price,
//           'qty': e.quantity,
//           'image': e.food.image,
//         }).toList(),
//         'total': cart.totalPrice,
//         'status': 'pending',
//         'paymentMethod': 'cash',
//         'paid': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       cart.clearCart();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Order placed successfully ✅")),
//       );

//       Navigator.popUntil(context, (r) => r.isFirst);
//     } catch (e) {
//       _showError("Failed to place order: $e");
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(
//                 labelText: 'Address',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: 'Phone',
//                 hintText: 'e.g. 254712345678',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _placeOrder,
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Place Order (Pay on Delivery)',
//                         style: TextStyle(fontSize: 18),
//                       ),
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

import '../../providers/cart_provider.dart';
import '../../providers/MyAuthProvider.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final address = _addressController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (address.isEmpty || phone.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
      _showError('Phone must start with 254 and have 12 digits');
      return;
    }

    final cart = context.read<CartProvider>();
    final auth = context.read<MyAuthProvider>();

    if (cart.items.isEmpty) {
      _showError("Cart is empty");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': auth.user?.uid,
        'userEmail': auth.user?.email,
        'address': address,
        'phone': phone,

        // ✅ FIXED ITEMS STRUCTURE
        'items': cart.items.values.map((e) => {
              'id': e.id,
              'name': e.name,
              'price': e.price,
              'qty': e.quantity,
              'image': e.imageUrl,
            }).toList(),

        'total': cart.totalPrice,
        'status': 'pending',
        'paymentMethod': 'cash',
        'paid': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      cart.clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully ✅")),
      );

      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      _showError("Failed to place order: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= SUMMARY =================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Items:"),
                      const Spacer(),
                      Text(cart.totalItems.toString()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text("Total:"),
                      const Spacer(),
                      Text("KES ${cart.totalPrice.toStringAsFixed(0)}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= ADDRESS =================
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ================= PHONE =================
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'e.g. 254712345678',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Place Order (Pay on Delivery)',
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
