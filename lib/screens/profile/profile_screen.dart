 import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  static const route = "/profile";
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // replace with provider user
    const userName = 'Ahmed';
    const email = 'ahmed@example.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              child: const Text('Edit Profile'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await AuthService().logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
