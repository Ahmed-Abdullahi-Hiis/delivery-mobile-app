import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/mpesa_service.dart';

class PaymentScreen extends StatefulWidget {
  final String address;
  final String phone;
  final double totalAmount;
  final List<Map<String, dynamic>> productNames;

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
  bool _stkSent = false;

  // Validate Kenyan phone number
  bool _isValidKenyanPhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'\D'), '');
    
    // Must be 10+ digits (for Kenyan numbers)
    if (normalized.length < 10) return false;
    
    // If starts with 0, it should be a Kenyan format
    if (phone.startsWith('0') && normalized.length == 10) return true;
    
    // If starts with +254, check format
    if (phone.startsWith('+254') && normalized.length == 12) return true;
    
    // If 254xxxxxxxxx format
    if (phone.startsWith('254') && normalized.length == 12) return true;
    
    return false;
  }

  // ================= START PAYMENT =================
  Future<void> _startPayment() async {
    // Validate phone first
    if (!_isValidKenyanPhone(widget.phone)) {
      _fail('❌ Invalid phone number! Use format: 0700000000 or +254700000000');
      return;
    }

    setState(() {
      _loading = true;
      _message = "📱 Sending M-Pesa prompt to ${widget.phone}...";
      _stkSent = false;
    });

    try {
      // Generate order ID
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

      print('🔄 Initiating payment for phone: ${widget.phone}');

      // Initiate STK push with M-Pesa service
      final result = await MpesaService.initiateSTKPush(
        phone: widget.phone,
        amount: widget.totalAmount,
        orderId: orderId,
        description: 'Food delivery order',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        print('✅ STK sent successfully');
        
        // Save the order
        await _saveOrder(orderId);

        // Get the actual M-Pesa message from response
        final mpesaMessage = result['customerMessage'] ?? result['message'] ?? '✅ M-Pesa prompt sent!';

        setState(() {
          _stkSent = true;
          _message = '✅ Payment Initiated!\n\n📱 Check your phone\n\n$mpesaMessage';
          _loading = false;
        });

      } else {
        print('❌ Payment failed: ${result['message']}');
        _fail(result['message'] ?? '❌ Payment initiation failed');
      }
    } catch (e) {
      print('❌ Payment error: $e');
      _fail("❌ Error: ${e.toString()}");
    }
  }

  // ================= SAVE ORDER =================
  Future<void> _saveOrder(String orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ User not authenticated');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.email,
        'items': widget.productNames,
        'total': widget.totalAmount.toInt(),
        'address': widget.address,
        'phone': widget.phone,
        'status': 'pending',
        'paymentMethod': 'mpesa',
        'paid': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order saved: $orderId');
    } catch (e) {
      print('❌ Error saving order: $e');
    }
  }

  // ================= ERROR HANDLER =================
  void _fail(String msg) {
    setState(() {
      _loading = false;
      _message = msg;
      _stkSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("M-Pesa Payment"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone number display
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'Phone: ${widget.phone}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: KES ${widget.totalAmount.toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Main message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _stkSent ? Colors.green[50] : Colors.orange[50],
                  border: Border.all(
                    color: _stkSent ? Colors.green : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _stkSent ? Colors.green[900] : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    if (_stkSent) ...[
                      const SizedBox(height: 16),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Loading indicator or button
              if (_loading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                )
              else if (_stkSent)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '⏱️ Waiting for M-Pesa...',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You have 2 minutes to enter your PIN',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startPayment,
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      "Pay with M-Pesa",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📌 Works with any Kenyan phone number:\n'
                  '• 0700000000\n'
                  '• +254700000000\n'
                  '• 254700000000',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
