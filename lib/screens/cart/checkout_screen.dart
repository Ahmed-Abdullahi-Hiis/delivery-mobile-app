import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'payment_screen.dart';

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
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (address.isEmpty) {
      _showError('Please enter delivery address');
      return false;
    }

    if (phone.isEmpty) {
      _showError('Please enter phone number');
      return false;
    }

    // Basic phone validation for Kenyan numbers
    String normalized = phone.replaceAll(RegExp(r'\D'), '');
    
    if (normalized.length < 9) {
      _showError('Phone number too short');
      return false;
    }

    if (normalized.length > 12) {
      _showError('Phone number too long');
      return false;
    }

    return true;
  }

  void _proceedToPayment() {
    if (!_validateInputs()) return;

    final cart = context.read<CartProvider>();
    
    if (cart.items.isEmpty) {
      _showError('Your cart is empty');
      return;
    }

    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    // Convert CartItem objects to maps with all necessary fields
    final items = cart.items.values.map((item) => {
      'id': item.id,
      'name': item.name,
      'price': item.price,
      'imageUrl': item.imageUrl,
      'qty': item.quantity,
    }).toList();

    // Navigate to payment screen - DO NOT show success here
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          address: address,
          phone: phone,
          totalAmount: widget.totalAmount,
          productNames: items,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'KES ${widget.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Delivery Address
              Text(
                'Delivery Address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your full delivery address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Icons.location_on),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number
              Text(
                'Phone Number',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone (e.g. 0700000000 or +254700000000)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📱 Accepts: 0700000000, +254700000000, 254700000000',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _proceedToPayment,
                  icon: const Icon(Icons.payment),
                  label: const Text('Proceed to Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
