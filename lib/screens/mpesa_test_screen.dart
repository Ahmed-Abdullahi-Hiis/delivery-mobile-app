import 'package:flutter/material.dart';
import '../../services/mpesa_service.dart';

class MpesaTestScreen extends StatefulWidget {
  const MpesaTestScreen({super.key});

  @override
  State<MpesaTestScreen> createState() => _MpesaTestScreenState();
}

class _MpesaTestScreenState extends State<MpesaTestScreen> {
  final _phoneController = TextEditingController(text: '+254793027220');
  final _amountController = TextEditingController(text: '100');
  bool _loading = false;
  String _message = "Ready to test M-Pesa integration";
  String _messageColor = "black";

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _loading = false;
      _message = "❌ $message";
      _messageColor = "red";
    });
  }

  Future<void> _testInitiatePayment() async {
    String phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    String amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    setState(() {
      _loading = true;
      _message = "📱 Sending M-Pesa prompt to $phone...";
      _messageColor = "black";
    });

    try {
      final amount = double.parse(amountStr);
      final result = await MpesaService.initiateSTKPush(
        phone: phone,
        amount: amount,
        orderId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        description: 'M-Pesa Integration Test',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _message = "✅ STK Prompt initiated!\n\n"
              "🔐 Check your phone for M-Pesa popup\n"
              "Enter your PIN to complete payment\n\n"
              "Checkout ID: ${result['checkoutId']}";
          _messageColor = "green";
        });
      } else {
        setState(() {
          _message = "❌ Failed: ${result['message']}";
          _messageColor = "red";
        });
      }
    } on FormatException {
      setState(() {
        _message = "❌ Invalid amount. Enter a number like 100 or 500.5";
        _messageColor = "red";
      });
    } catch (e) {
      setState(() {
        _message = "❌ Error: $e";
        _messageColor = "red";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _testSendPrompt() async {
    String phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    setState(() {
      _loading = true;
      _message = "📱 Sending M-Pesa prompt to $phone...";
      _messageColor = "black";
    });

    try {
      final success = await MpesaService.sendPrompt(phone);

      if (!mounted) return;

      if (success) {
        setState(() {
          _message = "✅ M-Pesa prompt sent successfully!\n\n"
              "🔐 Check your phone and enter PIN to complete payment";
          _messageColor = "green";
        });
      } else {
        setState(() {
          _message = "❌ Failed to send prompt. Check phone number format.";
          _messageColor = "red";
        });
      }
    } catch (e) {
      setState(() {
        _message = "❌ Error: $e";
        _messageColor = "red";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("M-Pesa Integration Test"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Credentials Display
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Credentials:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Base URL: https://dillon-unextinct-esther.ngrok-free.dev",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Consumer Key: ***Ao7yisZJ6WPFTaCIxTosOdMoI",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Consumer Secret: ***gtdACBVgomZy9GAlKb2cS7MBi3ZtNAf",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number Input
              Text(
                "Phone Number:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter phone (e.g., +254793027220 or 0793027220)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              Text(
                "Amount (KES):",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 24),

              // Message Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageColor == "green"
                      ? Colors.green[50]
                      : _messageColor == "red"
                          ? Colors.red[50]
                          : Colors.grey[50],
                  border: Border.all(
                    color: _messageColor == "green"
                        ? Colors.green
                        : _messageColor == "red"
                            ? Colors.red
                            : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _messageColor == "green"
                        ? Colors.green[900]
                        : _messageColor == "red"
                            ? Colors.red[900]
                            : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _testInitiatePayment,
                        icon: const Icon(Icons.payment),
                        label: const Text("Test STK Push"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _testSendPrompt,
                        icon: const Icon(Icons.sms),
                        label: const Text("Send Prompt (+254793027220)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Info Box
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📱 Supported Phone Formats:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "✓ 0700000000 (Kenyan format)\n"
                        "✓ +254700000000 (International)\n"
                        "✓ 254700000000 (No +)",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        "🔐 What Happens Next:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "1. Click 'Send Prompt' or 'Test STK Push'\n"
                        "2. M-Pesa popup appears on phone\n"
                        "3. User sees amount & business name\n"
                        "4. User enters M-Pesa PIN\n"
                        "5. Payment confirmed or cancelled\n"
                        "6. Order created in Firestore",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
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
