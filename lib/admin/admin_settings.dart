 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSettings extends StatelessWidget {
  AdminSettings({super.key});

  final DocumentReference settingsRef =
      FirebaseFirestore.instance.collection('settings').doc('app');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: settingsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final maintenance = data['maintenance'] ?? false;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "App Settings",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              SwitchListTile(
                title: const Text("Maintenance Mode"),
                subtitle:
                    const Text("Disable app access for normal users"),
                value: maintenance,
                onChanged: (value) async {
                  await settingsRef.set(
                    {'maintenance': value},
                    SetOptions(merge: true),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
