// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../orders/order_success_screen.dart';

// class PaymentScreen extends StatefulWidget {
//   final bool useCard;
//   final String address;
//   final String phone;
//   final double totalAmount;
//   final List<String> productNames;

//   const PaymentScreen({
//     super.key,
//     required this.useCard,
//     required this.address,
//     required this.phone,
//     required this.totalAmount,
//     required this.productNames,
//   });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _loading = true;
//   String _message = "Processing payment...";
//   String? _orderId;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.useCard) {
//       _simulateCardPayment();
//     } else {
//       _startMpesaPayment();
//     }
//   }

//   Future<void> _simulateCardPayment() async {
//     debugPrint("[DEBUG] Simulating card payment...");
//     await Future.delayed(const Duration(seconds: 2));
//     _completeOrder();
//   }

//   Future<void> _startMpesaPayment() async {
//     try {
//       debugPrint("[DEBUG] Starting M-Pesa payment for ${widget.phone}");
//       final phone = widget.phone.replaceAll(' ', '');
//       final apiUrl = "https://your-backend.com/api/mpesa/stk-push";

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "phone": phone,
//           "amount": widget.totalAmount,
//           "product_name": widget.productNames.join(', '),
//         }),
//       );

//       final data = jsonDecode(response.body);
//       debugPrint("[DEBUG] STK Push response: $data");

//       if (response.statusCode == 200 && data['status'] == 'success') {
//         setState(() {
//           _message = "STK Push sent! Check your phone.";
//           _orderId = data['order_id']?.toString();
//         });
//         _pollPaymentStatus();
//       } else {
//         _fail(data['message'] ?? 'STK Push failed');
//       }
//     } catch (e) {
//       _fail("Payment error: $e");
//     }
//   }

//   Future<void> _pollPaymentStatus() async {
//     if (_orderId == null) return;
//     final apiUrl = "https://your-backend.com/api/mpesa/status/$_orderId";

//     while (true) {
//       await Future.delayed(const Duration(seconds: 5));
//       try {
//         final response = await http.get(Uri.parse(apiUrl));
//         final data = jsonDecode(response.body);
//         debugPrint("[DEBUG] Polling payment status: $data");

//         if (data['status'] == 'success') {
//           _completeOrder();
//           break;
//         } else if (data['status'] == 'cancelled') {
//           _fail("Payment cancelled or failed.");
//           break;
//         }
//       } catch (e) {
//         debugPrint("[DEBUG] Polling error: $e");
//       }
//     }
//   }

//   void _completeOrder() {
//     debugPrint("[DEBUG] Payment successful, navigating to OrderSuccessScreen");
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
//     );
//   }

//   void _fail(String msg) {
//     setState(() {
//       _loading = false;
//       _message = msg;
//     });
//     debugPrint("[DEBUG] Payment failed: $msg");
//   }

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
//                 child: Text(
//                   _message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
//                 ),
//               ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../orders/order_success_screen.dart';

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
  bool _loading = false;
  String _message = "";

  // 🔹 Use your live backend URL from Render
  final String _backendUrl = "https://mpesa-backend-bli2.onrender.com";

  @override
  void initState() {
    super.initState();
    _startMpesaPayment();
  }

  Future<void> _startMpesaPayment() async {
    setState(() {
      _loading = true;
      _message = "Processing M-Pesa payment...";
    });

    try {
      final phone = widget.phone.replaceAll(' ', '');
      final apiUrl = "$_backendUrl/api/mpesa/stk-push";

      debugPrint("[DEBUG] Sending STK Push to $apiUrl for $phone");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "amount": widget.totalAmount,
          "product_name": widget.productNames.join(', '),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      debugPrint("[DEBUG] STK Push response: $data");

      if (data['status'] == 'success') {
        setState(() {
          _message = "STK Push sent! Check your phone to complete payment.";
        });
        // Optionally navigate to order success, or wait for actual M-Pesa callback
      } else {
        _fail(data['message'] ?? 'STK Push failed');
      }
    } catch (e) {
      _fail("Payment error: $e");
    }
  }

  void _fail(String msg) {
    setState(() {
      _loading = false;
      _message = msg;
    });
    debugPrint("[DEBUG] Payment failed: $msg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_message, textAlign: TextAlign.center),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _startMpesaPayment,
                      child: const Text("Retry Payment"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
