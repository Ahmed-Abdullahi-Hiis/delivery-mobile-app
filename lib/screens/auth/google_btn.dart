import 'package:e_shop/admin/admin_dashboard.dart';
import 'package:e_shop/providers/MyAuthProvider.dart';
import 'package:e_shop/root_screens/root_screen.dart';
import 'package:e_shop/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class GoogleButton extends StatefulWidget {
  const GoogleButton({super.key});

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _loading = false;

  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _loading = true);

      await AuthService().signInWithGoogle();

      final auth = context.read<MyAuthProvider>();
      await auth.reloadUser();

      if (!mounted) return;

      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AdminDashboard.route);
      } else {
        Navigator.pushReplacementNamed(context, RootScreen.route);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        icon: Image.asset("assets/images/google.png", height: 24),
        label: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Sign in with Google"),
        onPressed: _loading ? null : _loginWithGoogle,
      ),
    );
  }
}
