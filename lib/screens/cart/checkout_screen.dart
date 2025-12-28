import 'package:flutter/material.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<String> productNames;

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.productNames,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          address: address,
          phone: phone,
          totalAmount: widget.totalAmount,
          productNames: widget.productNames,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                child: const Text(
                  'Proceed to Payment',
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
