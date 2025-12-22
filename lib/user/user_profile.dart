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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
              validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (v) => v == null || v.isEmpty ? "Enter email" : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                try {
                  await auth.updateProfile(name: _nameCtrl.text, email: _emailCtrl.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                }
              },
              child: const Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
