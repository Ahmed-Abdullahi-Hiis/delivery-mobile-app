 import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../root_screens/root_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            _loading ? const CircularProgressIndicator() : ElevatedButton(
              onPressed: () async {
                setState(() => _loading = true);
                try {
                  await AuthService().register(_email.text.trim(), _pass.text.trim());
                  Navigator.pushReplacementNamed(context, RootScreen.route);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
