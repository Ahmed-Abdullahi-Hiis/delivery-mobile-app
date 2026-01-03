 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static Future<void> createOrder({
    required double total,
    required List<String> products,
    required String address,
    required String phone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user.uid,
      'userEmail': user.email,
      'items': products,
      'total': total,
      'address': address,
      'phone': phone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
