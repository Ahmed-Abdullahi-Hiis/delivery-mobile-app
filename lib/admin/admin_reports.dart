 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReports extends StatelessWidget {
  AdminReports({super.key});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getCount(String collection) async {
    final snap = await firestore.collection(collection).get();
    return snap.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        getCount('users'),
        getCount('orders'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final usersCount = snapshot.data![0];
        final ordersCount = snapshot.data![1];

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _reportCard("Total Users", usersCount, Icons.people),
              _reportCard("Total Orders", ordersCount, Icons.shopping_cart),
            ],
          ),
        );
      },
    );
  }

  Widget _reportCard(String title, int value, IconData icon) {
    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value.toString(),
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
