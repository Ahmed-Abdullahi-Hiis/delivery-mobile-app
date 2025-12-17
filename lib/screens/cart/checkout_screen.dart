


// import 'package:flutter/material.dart';
// import 'payment_screen.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _address = TextEditingController();
//   final _phone = TextEditingController();
//   bool _useCard = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _address,
//               decoration: const InputDecoration(labelText: 'Delivery address'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _phone,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: 'Phone Number',
//                 hintText: 'e.g. 2547XXXXXXXX',
//               ),
//             ),
//             const SizedBox(height: 12),
//             SwitchListTile(
//               title: const Text('Pay with card (else M-Pesa)'),
//               value: _useCard,
//               onChanged: (v) => setState(() => _useCard = v),
//             ),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: () {
//                 final phone = _phone.text.trim();
//                 final address = _address.text.trim();

//                 if (address.isEmpty || phone.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill all fields')),
//                   );
//                   return;
//                 }

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => PaymentScreen(
//                       useCard: _useCard,
//                       address: address,
//                       phone: phone,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('Proceed to Payment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _useCard = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Validates input and navigates to PaymentScreen
  void _proceedToPayment() {
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!RegExp(r'^254\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must start with 254 and be 12 digits')),
      );
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
                labelText: 'Delivery Address',
                hintText: 'Enter your delivery address',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g. 2547XXXXXXXX',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Pay with card (else M-Pesa)'),
              value: _useCard,
              onChanged: (value) => setState(() => _useCard = value),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
