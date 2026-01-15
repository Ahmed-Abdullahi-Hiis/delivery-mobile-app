
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
//   String _role = 'user';
//   bool _loading = false;

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     _pass.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (_name.text.isEmpty ||
//         _email.text.isEmpty ||
//         _pass.text.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Fill all fields (password min 6 chars)')),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       await AuthService().register(
//         name: _name.text.trim(),
//         email: _email.text.trim(),
//         password: _pass.text.trim(),
//         role: _role,
//       );

//       await context.read<MyAuthProvider>().reloadUser();

//       final auth = context.read<MyAuthProvider>();

//       if (auth.isAdmin) {
//         Navigator.pushReplacementNamed(context, AdminDashboard.route);
//       } else {
//         Navigator.pushReplacementNamed(context, RootScreen.route);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
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
//               TextField(
//                 controller: _name,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//               ),
//               const SizedBox(height: 16),
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
//               const SizedBox(height: 16),

//               DropdownButton<String>(
//                 value: _role,
//                 items: const [
//                   DropdownMenuItem(value: 'user', child: Text('User')),
//                   DropdownMenuItem(value: 'admin', child: Text('Admin')),
//                 ],
//                 onChanged: (v) => setState(() => _role = v!),
//               ),

//               const SizedBox(height: 24),

//               _loading
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _register,
//                         child: const Text('Register'),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  // ---------------- CONTROLLERS ----------------
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _repeatPass = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  String _role = 'user';

  Uint8List? _pickedImageBytes;

  // ---------------- IMAGE PICKER ----------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _pickedImageBytes = await image.readAsBytes();
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _pickedImageBytes = await image.readAsBytes();
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
              ),
              if (_pickedImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Remove"),
                  onTap: () {
                    setState(() => _pickedImageBytes = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- CLOUDINARY UPLOAD ----------------
  Future<String?> uploadImageToCloudinary(Uint8List imageBytes, String fileName) async {
    const cloudName = 'dbuzpdgqo'; // 🔴 your teacher's cloudinary
    const uploadPreset = 'ecommerce3';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
    );

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      return data['secure_url'];
    } else {
      debugPrint("Cloudinary upload failed: $respStr");
      return null;
    }
  }

  // ---------------- REGISTER FUNCTION ----------------
  Future<void> _register() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Create Firebase user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Upload image
      final imageUrl = await uploadImageToCloudinary(
        _pickedImageBytes!,
        "$uid.jpg",
      );

      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // 3. Save user in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "role": _role,
        "image": imageUrl,
        "createdAt": Timestamp.now(),
      });

      // 4. Reload provider user
      await context.read<MyAuthProvider>().reloadUser();

      final auth = context.read<MyAuthProvider>();

      // 5. Navigate
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AdminDashboard.route);
      } else {
        Navigator.pushReplacementNamed(context, RootScreen.route);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _repeatPass.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // IMAGE PICKER
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: size.width * 0.18,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        _pickedImageBytes != null ? MemoryImage(_pickedImageBytes!) : null,
                    child: _pickedImageBytes == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (v) => v == null || v.length < 3 ? "Enter valid name" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => v == null || !v.contains("@") ? "Enter valid email" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6 ? "Min 6 characters" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _repeatPass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Repeat Password"),
                  validator: (v) => v != _pass.text ? "Passwords do not match" : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => setState(() => _role = v!),
                  decoration: const InputDecoration(labelText: "Role"),
                ),

                const SizedBox(height: 24),

                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: const Text("Register"),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
