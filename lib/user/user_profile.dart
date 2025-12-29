import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MyAuthProvider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<MyAuthProvider>();
    _nameCtrl = TextEditingController(text: auth.user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: auth.user?.email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MyAuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // ---------------- Profile Avatar ----------------
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                auth.user?.displayName != null
                    ? auth.user!.displayName![0].toUpperCase()
                    : "U",
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---------------- Profile Form Card ----------------
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Enter email" : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          try {
                            await auth.updateProfile(
                                name: _nameCtrl.text, email: _emailCtrl.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Profile updated successfully")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$e")),
                            );
                          }
                        },
                        label: const Text("Update Profile"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
