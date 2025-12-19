import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
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

  // Clear cart, add order, navigate to success screen
  void _completeOrder() {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    // Extract FoodModel from CartItem
    final orderItems = cart.items.values.map((c) => c.food).toList();

    // Add order
    orders.addOrder(
      items: orderItems,
      totalAmount: cart.totalPrice,
    );

    // Clear cart
    cart.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderSuccessScreen(),
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
