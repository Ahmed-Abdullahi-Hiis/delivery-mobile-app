//  import 'package:flutter/material.dart';
// import 'payment_screen.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _address = TextEditingController();
//   bool _useCard = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _address, decoration: const InputDecoration(labelText: 'Delivery address')),
//             const SizedBox(height: 12),
//             SwitchListTile(
//               title: const Text('Pay with card (else cash)'),
//               value: _useCard,
//               onChanged: (v) => setState(() => _useCard = v),
//             ),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: () {
//                 // proceed to payment
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(useCard: _useCard, address: _address.text)));
//               },
//               child: const Text('Proceed to Payment'),
//             )
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
  final _address = TextEditingController();
  final _phone = TextEditingController();
  bool _useCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Delivery address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
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
              onChanged: (v) => setState(() => _useCard = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final phone = _phone.text.trim();
                final address = _address.text.trim();

                if (address.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
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
              },
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
