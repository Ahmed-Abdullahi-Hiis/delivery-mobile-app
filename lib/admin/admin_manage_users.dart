import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminManageUsers extends StatelessWidget {
  // Remove const
  AdminManageUsers({super.key});

  // Firestore reference (runtime)
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: usersRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            final email = data['email'] ?? 'No Email';
            final role = data['role'] ?? 'user';

            return Card(
              child: ListTile(
                title: Text(email),
                subtitle: Text("Role: $role"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit role
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final newRole = role == 'admin' ? 'user' : 'admin';
                        await usersRef.doc(doc.id).update({'role': newRole});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$email is now $newRole')),
                        );
                      },
                    ),
                    // Delete user
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content:
                                Text('Are you sure you want to delete $email?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await usersRef.doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$email deleted')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
