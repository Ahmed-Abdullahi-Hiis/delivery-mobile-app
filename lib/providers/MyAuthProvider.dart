// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MyAuthProvider extends ChangeNotifier { // <- rename class
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   User? get user => _auth.currentUser;

//   Future<void> login(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//     notifyListeners();
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  // Update profile info (name + email)
  Future<void> updateProfile({String? name, String? email}) async {
    if (user == null) return;

    try {
      // Update display name
      if (name != null && name.isNotEmpty) {
        await user!.updateDisplayName(name);
      }

      // Update email
      if (email != null && email.isNotEmpty && email != user!.email) {
        try {
          await user!.updateEmail(email);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            // The user needs to re-login
            throw Exception(
                'Please re-login and try again to update your email.');
          } else {
            throw Exception('Failed to update email: ${e.message}');
          }
        }
      }

      // Reload user data to reflect changes
      await user!.reload();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
