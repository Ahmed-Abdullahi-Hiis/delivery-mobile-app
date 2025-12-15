import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool _isLoading = false;
  String _statusMessage = "Waiting for payment...";

  @override
  void initState() {
    super.initState();
    if (!widget.useCard) {
      _startMpesaPayment();
    } else {
      // Simulate card payment
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _statusMessage = "Card payment completed!");
        _clearCartAndShowConfirmation();
      });
    }
  }

  Future<void> _startMpesaPayment() async {
    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final amount = cart.totalPrice;

      // Replace with your local backend URL
      final url = Uri.parse("http://192.168.0.105:3000/mpesa/payment");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": widget.phone,
          "amount": amount,
          "address": widget.address,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() => _statusMessage = "Payment request sent! Check your phone for STK push.");
        _clearCartAndShowConfirmation();
      } else {
        setState(() => _statusMessage = "Payment failed: ${data['message']}");
      }
    } catch (e) {
      setState(() => _statusMessage = "Payment error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearCartAndShowConfirmation() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.clearCart();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Placed'),
        content: const Text('Your order has been placed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                _statusMessage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
