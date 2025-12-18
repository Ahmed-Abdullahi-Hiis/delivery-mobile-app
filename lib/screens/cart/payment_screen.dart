




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/cart_provider.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class PaymentScreen extends StatefulWidget {
//   final bool useCard;
//   final String address;
//   final String phone;

//   const PaymentScreen({
//     super.key,
//     required this.useCard,
//     required this.address,
//     required this.phone,
//   });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _isLoading = false;
//   String _statusMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     if (widget.useCard) {
//       _simulateCardPayment();
//     } else {
//       _startMpesaPayment();
//     }
//   }

//   // Simulated card payment
//   void _simulateCardPayment() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = "Processing card payment...";
//     });

//     await Future.delayed(const Duration(seconds: 2));
//     setState(() => _isLoading = false);
//     _showConfirmationDialog("Card payment completed!");
//     _clearCart();
//   }

//   // M-Pesa STK Push payment
//   Future<void> _startMpesaPayment() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = "Sending M-Pesa payment request...";
//     });

//     try {
//       final cart = Provider.of<CartProvider>(context, listen: false);
//       final amount = cart.totalPrice;

//       // Replace with your backend URL
//       final url = Uri.parse("http://192.168.0.105:3000/mpesa/payment");

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "phone": widget.phone,
//           "amount": amount,
//           "address": widget.address,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == 'success') {
//         setState(() => _statusMessage = "Payment request sent! Check your phone for STK push.");
//         _showConfirmationDialog("Payment request sent! Check your phone for STK push.");
//         _clearCart();
//       } else {
//         setState(() => _statusMessage = "Payment failed: ${data['message']}");
//       }
//     } catch (e) {
//       setState(() => _statusMessage = "Payment error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // Clear cart
//   void _clearCart() {
//     final cart = Provider.of<CartProvider>(context, listen: false);
//     cart.clearCart();
//   }

//   // Show confirmation dialog
//   void _showConfirmationDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Order Status'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.popUntil(context, (route) => route.isFirst);
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: Center(
//         child: _isLoading
//             ? const CircularProgressIndicator()
//             : Text(
//                 _statusMessage.isEmpty ? "Waiting for payment..." : _statusMessage,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../providers/cart_provider.dart';
import '../orders/order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final bool useCard;
  final String address;
  final String phone;

  const PaymentScreen({
    super.key,
    required this.useCard,
    required this.address,
    required this.phone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = true;
  String _message = "Processing payment...";

  @override
  void initState() {
    super.initState();
    if (widget.useCard) {
      _simulateCardPayment();
    } else {
      _startMpesaPayment();
    }
  }

  // 💳 Simulated Card Payment
  Future<void> _simulateCardPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    _completeOrder();
  }

  // 📲 M-Pesa Payment
  Future<void> _startMpesaPayment() async {
    try {
      final cart = context.read<CartProvider>();
      final response = await http.post(
        Uri.parse("http://192.168.0.105:3000/mpesa/payment"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": widget.phone,
          "amount": cart.totalPrice,
          "address": widget.address,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        _completeOrder();
      } else {
        _fail(data['message'] ?? 'Payment failed');
      }
    } catch (e) {
      _fail("Payment error: $e");
    }
  }

  // Clear cart and navigate to success screen
  void _completeOrder() {
    context.read<CartProvider>().clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(), // ❌ remove const
      ),
    );
  }

  void _fail(String msg) {
    setState(() {
      _loading = false;
      _message = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
      ),
    );
  }
}
