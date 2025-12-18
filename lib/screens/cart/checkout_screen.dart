

import 'package:flutter/material.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _useCard = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
      _showError('Phone must start with 254');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          useCard: _useCard,
          address: address,
          phone: phone,
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
              controller: _addressCtrl,
              decoration:
                  const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Pay with card'),
              subtitle:
                  const Text('Turn off to use M-Pesa'),
              value: _useCard,
              onChanged: (v) => setState(() => _useCard = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
