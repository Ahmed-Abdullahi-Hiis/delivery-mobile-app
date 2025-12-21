
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MyAuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   User? get user => _auth.currentUser;

//   // Update profile info (name + email)
//   Future<void> updateProfile({String? name, String? email}) async {
//     if (user == null) return;

//     try {
//       // Update display name
//       if (name != null && name.isNotEmpty) {
//         await user!.updateDisplayName(name);
//       }

//       // Update email
//       if (email != null && email.isNotEmpty && email != user!.email) {
//         try {
//           await user!.updateEmail(email);
//         } on FirebaseAuthException catch (e) {
//           if (e.code == 'requires-recent-login') {
//             // The user needs to re-login
//             throw Exception(
//                 'Please re-login and try again to update your email.');
//           } else {
//             throw Exception('Failed to update email: ${e.message}');
//           }
//         }
//       }

//       // Reload user data to reflect changes
//       await user!.reload();
//       notifyListeners();
//     } catch (e) {
//       throw Exception('Failed to update profile: $e');
//     }
//   }

//   // Logout
//   Future<void> logout() async {
//     await _auth.signOut();
//     notifyListeners();
//   }
// }






import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  String role = 'user';
  bool get isAdmin => role == 'admin';

  /// 🔐 Load role from Firestore (SAFE for old users)
  Future<void> loadUserRole() async {
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);

    final doc = await ref.get();

    // ✅ FIX: auto-create user doc if missing
    if (!doc.exists) {
      await ref.set({
        'email': user!.email,
        'role': 'user',
      });
      role = 'user';
    } else {
      role = doc.data()?['role'] ?? 'user';
    }

    notifyListeners();
  }

  /// 👤 Update profile info (name + email)
  Future<void> updateProfile({String? name, String? email}) async {
    if (user == null) return;

    try {
      if (name != null && name.isNotEmpty) {
        await user!.updateDisplayName(name);
      }

      if (email != null && email.isNotEmpty && email != user!.email) {
        try {
          await user!.updateEmail(email);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            throw Exception(
              'Please re-login and try again to update your email.',
            );
          } else {
            throw Exception('Failed to update email: ${e.message}');
          }
        }
      }

      await user!.reload();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    role = 'user'; // reset role
    notifyListeners();
  }
}
