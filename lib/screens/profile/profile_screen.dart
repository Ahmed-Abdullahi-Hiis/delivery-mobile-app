import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import '../../providers/MyAuthProvider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const route = "/profile";
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<MyAuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'No Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? 'No Email'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              child: const Text('Edit Profile'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  // Call provider logout
                  await context.read<MyAuthProvider>().logout();

                  // Navigate to login and remove all previous routes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.route,
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
