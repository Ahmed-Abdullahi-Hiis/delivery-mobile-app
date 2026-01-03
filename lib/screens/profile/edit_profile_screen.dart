// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/MyAuthProvider.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   late TextEditingController _name;
//   late TextEditingController _email;

//   @override
//   void initState() {
//     super.initState();
//     final user = context.read<MyAuthProvider>().user;
//     _name = TextEditingController(text: user?.displayName ?? '');
//     _email = TextEditingController(text: user?.email ?? '');
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
//             const SizedBox(height: 8),
//             TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 context.read<MyAuthProvider>().updateProfile(
//                       name: _name.text.trim(),
//                       email: _email.text.trim(),
//                     );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Profile updated')),
//                 );
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }










import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MyAuthProvider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _email;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<MyAuthProvider>();
    _name = TextEditingController(text: auth.user?.displayName ?? '');
    _email = TextEditingController(text: auth.user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      await context.read<MyAuthProvider>().updateProfile(
            name: _name.text.trim(),
            email: _email.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
          ],
        ),
      ),
    );
  }
}
