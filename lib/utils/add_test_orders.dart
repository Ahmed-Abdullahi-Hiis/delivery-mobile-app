 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTestOrdersScreen extends StatelessWidget {
  const AddTestOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Test Orders")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You must be logged in first.")),
              );
              return;
            }

            final ordersRef = FirebaseFirestore.instance.collection('orders');

            // Example test orders
            final testOrders = [
              {
                'userId': user.uid,
                'userEmail': user.email ?? 'unknown',
                'total': 15.99,
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              },
              {
                'userId': user.uid,
                'userEmail': user.email ?? 'unknown',
                'total': 29.50,
                'status': 'delivered',
                'createdAt': FieldValue.serverTimestamp(),
              },
            ];

            try {
              for (var order in testOrders) {
                await ordersRef.add(order);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Test orders added successfully!")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          child: const Text("Add Test Orders"),
        ),
      ),
    );
  }
}
