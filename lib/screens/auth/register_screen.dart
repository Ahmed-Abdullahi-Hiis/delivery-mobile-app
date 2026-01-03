
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../providers/MyAuthProvider.dart';
// import '../../root_screens/root_screen.dart';
// import '../../admin/admin_dashboard.dart';

// class RegisterScreen extends StatefulWidget {
//   static const route = "/register";
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _pass = TextEditingController();
//   String _selectedRole = 'user'; // default role
//   bool _loading = false;

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     _pass.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (_name.text.isEmpty || _email.text.isEmpty || _pass.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('All fields are required')),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       // Register with AuthService and save role
//       await AuthService().register(
//         name: _name.text.trim(),
//         email: _email.text.trim(),
//         password: _pass.text.trim(),
//         role: _selectedRole,
//       );

//       // Wait for provider to load role
//       final authProvider = context.read<MyAuthProvider>();
//       await Future.doWhile(() async {
//         await Future.delayed(const Duration(milliseconds: 100));
//         return authProvider.isLoading;
//       });

//       // Navigate based on role
//       if (authProvider.isAdmin) {
//         Navigator.pushReplacementNamed(context, AdminDashboard.route);
//       } else {
//         Navigator.pushReplacementNamed(context, RootScreen.route);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registration failed: $e')),
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

//               // Full Name
//               TextField(
//                 controller: _name,
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   prefixIcon: const Icon(Icons.person),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Email
//               TextField(
//                 controller: _email,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: const Icon(Icons.email),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Password
//               TextField(
//                 controller: _pass,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: const Icon(Icons.lock),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Role selection
//               Row(
//                 children: [
//                   const Text('Role:'),
//                   const SizedBox(width: 16),
//                   DropdownButton<String>(
//                     value: _selectedRole,
//                     items: const [
//                       DropdownMenuItem(value: 'user', child: Text('User')),
//                       DropdownMenuItem(value: 'admin', child: Text('Admin')),
//                     ],
//                     onChanged: (val) {
//                       if (val != null) setState(() => _selectedRole = val);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               _loading
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _register,
//                         child: const Text('Register', style: TextStyle(fontSize: 16)),
//                       ),
//                     ),
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
import '../../root_screens/root_screen.dart';
import '../../admin/admin_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  static const route = "/register";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _role = 'user';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _pass.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields (password min 6 chars)')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pass.text.trim(),
        role: _role,
      );

      await context.read<MyAuthProvider>().reloadUser();

      final auth = context.read<MyAuthProvider>();

      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AdminDashboard.route);
      } else {
        Navigator.pushReplacementNamed(context, RootScreen.route);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),

              DropdownButton<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),

              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text('Register'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
