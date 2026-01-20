


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:iconly/iconly.dart';

// import '../../services/auth_service.dart';
// import '../../providers/MyAuthProvider.dart';
// import '../../root_screens/root_screen.dart';
// import '../../admin/admin_dashboard.dart';
// import '../auth/register_screen.dart';
// import '../auth/forgot_password.dart';
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

//   final _formKey = GlobalKey<FormState>();

//   bool _loading = false;
//   bool _obscure = true;

//   @override
//   void dispose() {
//     _email.dispose();
//     _pass.dispose();
//     super.dispose();
//   }

//   /// 🔐 EMAIL LOGIN
//   Future<void> _login() async {
//     final isValid = _formKey.currentState!.validate();
//     FocusScope.of(context).unfocus();

//     if (!isValid) return;

//     setState(() => _loading = true);

//     try {
//       await AuthService().login(
//         _email.text.trim(),
//         _pass.text.trim(),
//       );

//       final auth = context.read<MyAuthProvider>();
//       await auth.reloadUser();

//       if (!mounted) return;

//       if (auth.isAdmin) {
//         Navigator.pushReplacementNamed(context, AdminDashboard.route);
//       } else {
//         Navigator.pushReplacementNamed(context, RootScreen.route);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Login failed: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   /// 🔵 GOOGLE LOGIN
//   Future<void> _loginWithGoogle() async {
//     try {
//       setState(() => _loading = true);

//       await AuthService().signInWithGoogle();

//       final auth = context.read<MyAuthProvider>();
//       await auth.reloadUser();

//       if (!mounted) return;

//       if (auth.isAdmin) {
//         Navigator.pushReplacementNamed(context, AdminDashboard.route);
//       } else {
//         Navigator.pushReplacementNamed(context, RootScreen.route);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Google sign-in failed: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 32),

//                       const Text(
//                         "Welcome Back 👋",
//                         style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                       ),

//                       const SizedBox(height: 24),

//                       TextFormField(
//                         controller: _email,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: const InputDecoration(
//                           hintText: "Email address",
//                           prefixIcon: Icon(IconlyLight.message),
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (v) =>
//                             v == null || !v.contains("@") ? "Enter valid email" : null,
//                       ),

//                       const SizedBox(height: 16),

//                       TextFormField(
//                         controller: _pass,
//                         obscureText: _obscure,
//                         decoration: InputDecoration(
//                           hintText: "********",
//                           prefixIcon: const Icon(IconlyLight.lock),
//                           border: const OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
//                             onPressed: () => setState(() => _obscure = !_obscure),
//                           ),
//                         ),
//                         validator: (v) =>
//                             v == null || v.length < 6 ? "Password too short" : null,
//                         onFieldSubmitted: (_) => _login(),
//                       ),

//                       const SizedBox(height: 16),

//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
//                             );
//                           },
//                           child: const Text(
//                             "Forgot password?",
//                             style: TextStyle(decoration: TextDecoration.underline),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // EMAIL LOGIN
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.login),
//                           label: const Text("Login"),
//                           onPressed: _loading ? null : _login,
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // GOOGLE LOGIN
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: Colors.black,
//                           ),
//                           icon: Image.asset("assets/images/google.png", height: 24),
//                           label: const Text("Sign in with Google"),
//                           onPressed: _loading ? null : _loginWithGoogle,
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Don't have an account?"),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const RegisterScreen()),
//                               );
//                             },
//                             child: const Text(
//                               "Create one",
//                               style: TextStyle(decoration: TextDecoration.underline),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => const HomeScreen()),
//                           );
//                         },
//                         child: const Text("Continue as Guest"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // 🔄 LOADING OVERLAY
//             if (_loading)
//               Container(
//                 color: Colors.black26,
//                 child: const Center(child: CircularProgressIndicator()),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';

import '../../services/auth_service.dart';
import '../../providers/MyAuthProvider.dart';
import '../../root_screens/root_screen.dart';
import '../../admin/admin_dashboard.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ===============================
  // 🔐 EMAIL LOGIN
  // ===============================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      await AuthService().login(
        _email.text.trim(),
        _pass.text.trim(),
      );

      await _handlePostLogin();
    } catch (e) {
      _showError("Login failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===============================
  // 🔵 GOOGLE LOGIN
  // ===============================
  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);

    try {
      await AuthService().signInWithGoogle();
      await _handlePostLogin();
    } catch (e) {
      _showError("Google sign-in failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===============================
  // 🧠 COMMON POST-LOGIN LOGIC
  // ===============================
  Future<void> _handlePostLogin() async {
    final auth = context.read<MyAuthProvider>();
    await auth.reloadUser();

    if (!mounted) return;

    if (auth.isAdmin) {
      Navigator.pushReplacementNamed(context, AdminDashboard.route);
    } else {
      Navigator.pushReplacementNamed(context, RootScreen.route);
    }
  }

  // ===============================
  // ❌ ERROR SNACKBAR
  // ===============================
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= EMAIL =================
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email address",
                          prefixIcon: Icon(IconlyLight.message),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || !v.contains("@") ? "Enter valid email" : null,
                      ),

                      const SizedBox(height: 16),

                      // ================= PASSWORD =================
                      TextFormField(
                        controller: _pass,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: "********",
                          prefixIcon: const Icon(IconlyLight.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscure = !_obscure);
                            },
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.length < 6 ? "Password too short" : null,
                        onFieldSubmitted: (_) => _login(),
                      ),

                      const SizedBox(height: 12),

                      // ================= FORGOT =================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= EMAIL LOGIN BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text("Login"),
                          onPressed: _loading ? null : _login,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= GOOGLE LOGIN BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          icon: Image.asset(
                            "assets/images/google.png",
                            height: 24,
                          ),
                          label: const Text("Sign in with Google"),
                          onPressed: _loading ? null : _loginWithGoogle,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= REGISTER =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Create one",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ================= GUEST =================
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text("Continue as Guest"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================= LOADING OVERLAY =================
            if (_loading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
