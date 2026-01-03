// import 'package:flutter/material.dart';

// class OrderSuccessScreen extends StatelessWidget {
//   static const route = '/order-success';

//   const OrderSuccessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Success Icon
//             Container(
//               width: 120,
//               height: 120,
//               decoration: const BoxDecoration(
//                 color: Colors.green,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check,
//                 size: 70,
//                 color: Colors.white,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Title
//             const Text(
//               "Order Placed!",
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Subtitle
//             const Text(
//               "Your food is on the way 🍔",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),

//             const SizedBox(height: 40),

//             // Button → User Dashboard
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/user-dashboard', // SAFE string route
//                   (_) => false,
//                 );
//               },
//               child: const Text(
//                 "View My Orders",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Optional Home button
//             TextButton(
//               onPressed: () {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/home',
//                   (_) => false,
//                 );
//               },
//               child: const Text("Back to Home"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const route = '/order-success';
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              "Order Placed!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your food is on the way 🍔",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/user-dashboard',
                  (_) => false,
                );
              },
              child: const Text("View My Orders"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                );
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
