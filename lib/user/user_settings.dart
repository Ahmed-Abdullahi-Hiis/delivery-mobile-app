 import 'package:flutter/material.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: true, // you can integrate with Firestore/user prefs later
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: false, // integrate with theme provider if needed
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
