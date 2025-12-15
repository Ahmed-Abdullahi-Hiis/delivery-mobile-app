 import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool dark = false;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            value: dark,
            onChanged: (_) {
              // connect to theme provider
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Help & Support'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
