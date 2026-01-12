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
  bool _loading = false;
  String _message = "Ready to pay";

  // 🔥 YOUR FIREBASE BACKEND
  final String _backendUrl = "https://e-shop-836cc.cloudfunctions.net/api";

  // ================= START PAYMENT =================
  Future<void> _startPayment() async {
    setState(() {
      _loading = true;
      _message = "Sending payment request...";
    });

    try {
      // Ensure phone is in 2547XXXXXXXX format
      final phone = widget.phone.startsWith('0')
          ? '254${widget.phone.substring(1)}'
          : widget.phone;

      final response = await http.post(
        Uri.parse("$_backendUrl/initiate-stk-push"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "amount": widget.totalAmount.round(), // must be integer
        }),
      );

      final data = jsonDecode(response.body);

      // ✅ SUCCESS CONDITION FROM MPESA
      if (response.statusCode == 200 && data['ResponseCode'] == '0') {
        await _saveOrder();

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/order-success',
          (_) => false,
        );
      } else {
        _fail(data['error'] ?? data['ResponseDescription'] ?? "Payment failed");
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
      'total': widget.totalAmount.round(),
      'address': widget.address,
      'phone': widget.phone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ERROR HANDLER =================
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _loading ? Colors.black : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (_loading) const CircularProgressIndicator(),

            if (!_loading)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _startPayment,
                  child: const Text(
                    "Pay with M-Pesa",
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
