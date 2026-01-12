
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../services/auth_service.dart';
// import '../../providers/MyAuthProvider.dart';
// import '../auth/register_screen.dart';
// import '../auth/forgot_password.dart';
// import '../../root_screens/root_screen.dart';
// import '../../admin/admin_dashboard.dart';
// import '../home/home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   static const route = "/login";
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _email = TextEditingController();
//   final _pass = TextEditingController();
//   bool _loading = false;

//   @override
//   void dispose() {
//     _email.dispose();
//     _pass.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (_email.text.isEmpty || _pass.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Email and password required')),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       // ✅ Firebase Auth login
//       await AuthService().login(
//         _email.text.trim(),
//         _pass.text.trim(),
//       );

//       // ✅ Reload user + role
//       final auth = context.read<MyAuthProvider>();
//       await auth.reloadUser();

//       if (!mounted) return;

//       // ✅ Navigate by role
//       if (auth.isAdmin) {
//         Navigator.pushReplacementNamed(
//           context,
//           AdminDashboard.route,
//         );
//       } else {
//         Navigator.pushReplacementNamed(
//           context,
//           RootScreen.route,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               const SizedBox(height: 32),

//               TextField(
//                 controller: _email,
//                 decoration: const InputDecoration(labelText: 'Email'),
//               ),
//               const SizedBox(height: 16),

//               TextField(
//                 controller: _pass,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Password'),
//               ),
//               const SizedBox(height: 24),

//               _loading
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         child: const Text('Login'),
//                       ),
//                     ),

//               TextButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const RegisterScreen()),
//                 ),
//                 child: const Text('Create an account'),
//               ),

//               TextButton(
//                 onPressed: () => Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const HomeScreen()),
//                 ),
//                 child: const Text('Continue as Guest'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../providers/MyAuthProvider.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password.dart';
import '../../root_screens/root_screen.dart';
import '../../admin/admin_dashboard.dart';
import '../home/home_screen.dart';

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
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1️⃣ Login with Firebase
      await AuthService().login(
        _email.text.trim(),
        _pass.text.trim(),
      );

      // 2️⃣ Reload user + role
      final auth = context.read<MyAuthProvider>();
      await auth.reloadUser();

      if (!mounted) return;

      // 3️⃣ Navigate by role
      if (auth.isAdmin) {
        // 👑 Admin goes to admin panel
        Navigator.pushReplacementNamed(context, AdminDashboard.route);
      } else {
        // 👤 Normal user goes to shopping home
        Navigator.pushReplacementNamed(context, RootScreen.route);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Create an account'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text('Forgot password?'),
              ),

              const Divider(height: 32),

              TextButton(
                onPressed: () {
                  // 👤 Guest goes to home (no login)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
