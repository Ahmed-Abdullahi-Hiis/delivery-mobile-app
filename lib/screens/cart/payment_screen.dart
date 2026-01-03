// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';

// import '../../providers/cart_provider.dart';
// import '../orders/order_success_screen.dart';

// class PaymentScreen extends StatefulWidget {
//   final String address;
//   final String phone;
//   final double totalAmount;
//   final List<String> productNames;

//   const PaymentScreen({
//     super.key,
//     required this.address,
//     required this.phone,
//     required this.totalAmount,
//     required this.productNames,
//   });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _loading = false;
//   String _message = "";

//   /// 🔹 Live backend URL
//   final String _backendUrl = "https://mpesa-backend-bli2.onrender.com";

//   @override
//   void initState() {
//     super.initState();
//     _startMpesaPayment();
//   }

//   // ================= MPESA PAYMENT =================
//   Future<void> _startMpesaPayment() async {
//     setState(() {
//       _loading = true;
//       _message = "Processing M-Pesa payment...";
//     });

//     try {
//       final phone = widget.phone.replaceAll(' ', '');
//       final apiUrl = "$_backendUrl/api/mpesa/stk-push";

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "phone": phone,
//           "amount": widget.totalAmount,
//           "product_name": widget.productNames.join(', '),
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception("HTTP ${response.statusCode}: ${response.body}");
//       }

//       final data = jsonDecode(response.body);

//       if (data['status'] == 'success') {
//         setState(() {
//           _message = "STK Push sent! Check your phone to complete payment.";
//         });

//         // 🔥 SAVE ORDER TO FIRESTORE
//         await _saveOrder();
//       } else {
//         _fail(data['message'] ?? 'STK Push failed');
//       }
//     } catch (e) {
//       _fail("Payment error: $e");
//     }
//   }

//   // ================= SAVE ORDER =================
//   Future<void> _saveOrder() async {
//     final user = FirebaseAuth.instance.currentUser!;
//     final cart = context.read<CartProvider>();

//     await FirebaseFirestore.instance.collection('orders').add({
//       'userId': user.uid,
//       'userEmail': user.email,
//       'address': widget.address,
//       'phone': widget.phone,
//       'items': widget.productNames,
//       'total': widget.totalAmount,
//       'status': 'pending', // admin updates later
//       'paymentMethod': 'mpesa',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     cart.clearCart();

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
//     );
//   }

//   // ================= ERROR HANDLER =================
//   void _fail(String msg) {
//     setState(() {
//       _loading = false;
//       _message = msg;
//     });
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: Center(
//         child: _loading
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(height: 16),
//                   Text(_message, textAlign: TextAlign.center),
//                 ],
//               )
//             : Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       _message,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _startMpesaPayment,
//                       child: const Text("Retry Payment"),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String address;
  final String phone;
  final double totalAmount;
  final List<String> productNames;

  const PaymentScreen({
    super.key,
    required this.address,
    required this.phone,
    required this.totalAmount,
    required this.productNames,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = true;
  String _message = "Processing payment...";

  final String _backendUrl = "https://mpesa-backend-bli2.onrender.com";

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  // ================= START PAYMENT =================
  Future<void> _startPayment() async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/api/mpesa/stk-push"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": widget.phone,
          "amount": widget.totalAmount,
          "product_name": widget.productNames.join(', '),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        await _saveOrder();

        // ✅ SAFE navigation (no undefined error)
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/order-success',
          (_) => false,
        );
      } else {
        _fail(data['message'] ?? "Payment failed");
      }
    } catch (e) {
      _fail("Payment error: $e");
    }
  }

  // ================= SAVE ORDER =================
  Future<void> _saveOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user.uid,
      'userEmail': user.email,
      'items': widget.productNames,
      'total': widget.totalAmount,
      'address': widget.address,
      'phone': widget.phone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ERROR =================
  void _fail(String msg) {
    setState(() {
      _loading = false;
      _message = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Center(
        child: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _message = "Retrying payment...";
                        });
                        _startPayment();
                      },
                      child: const Text("Retry Payment"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
