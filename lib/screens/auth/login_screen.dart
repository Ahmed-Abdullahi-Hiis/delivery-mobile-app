

// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
// import '../auth/register_screen.dart';
// import '../../root_screens/root_screen.dart';
// import '../auth/forgot_password.dart';

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
//         const SnackBar(content: Text('All fields are required')),
//       );
//       return;
//     }

//     setState(() => _loading = true);
//     try {
//       await AuthService().login(
//         _email.text.trim(),
//         _pass.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, RootScreen.route);
//     } catch (_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid email or password')),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // const FlutterLogo(size: 100),
//               const SizedBox(height: 32),
//               TextField(
//                 controller: _email,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   hintText: 'Enter your email',
//                   prefixIcon: const Icon(Icons.email),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _pass,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   prefixIcon: const Icon(Icons.lock),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _loading
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text('Login', style: TextStyle(fontSize: 16)),
//                       ),
//                     ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () =>
//                     Navigator.pushNamed(context, ForgotPasswordScreen.route),
//                 child: const Text('Forgot password?'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const RegisterScreen()),
//                 ),
//                 child: const Text('Create an account'),
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

// import '../../root_screens/root_screen.dart';
// import '../../admin/admin_dashboard.dart';

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
      const SnackBar(content: Text('All fields are required')),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    // 1️⃣ Firebase Auth login
    await AuthService().login(
      _email.text.trim(),
      _pass.text.trim(),
    );

    // 2️⃣ Load user role from Firestore
    final auth = context.read<MyAuthProvider>();
    await auth.loadUserRole();

    if (!mounted) return;

    // 3️⃣ Redirect based on role
    if (auth.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/root');
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}







  // Future<void> _login() async {
  //   if (_email.text.isEmpty || _pass.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('All fields are required')),
  //     );
  //     return;
  //   }

  //   setState(() => _loading = true);

  //   try {
  //     // 1️⃣ Login
  //     await AuthService().login(
  //       _email.text.trim(),
  //       _pass.text.trim(),
  //     );

  //     // 2️⃣ Load user role
  //     final auth = context.read<MyAuthProvider>();
  //     await auth.loadUserRole();

  //     if (!mounted) return;

  //     // 3️⃣ Redirect based on role
  //     if (auth.isAdmin) {
  //       Navigator.pushReplacementNamed(
  //         context,
  //         AdminDashboard.route,
  //       );
  //     } else {
  //       Navigator.pushReplacementNamed(
  //         context,
  //         RootScreen.route,
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Invalid email or password')),
  //     );
  //   } finally {
  //     setState(() => _loading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),

              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, ForgotPasswordScreen.route),
                child: const Text('Forgot password?'),
              ),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
