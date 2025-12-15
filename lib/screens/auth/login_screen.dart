import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/register_screen.dart';
import '../../root_screens/root_screen.dart';

class LoginScreen extends StatefulWidget {
  static const route = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                  await AuthService().login(_email.text.trim(), _pass.text.trim());
                  Navigator.pushReplacementNamed(context, RootScreen.route);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Create an account'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot'),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}
