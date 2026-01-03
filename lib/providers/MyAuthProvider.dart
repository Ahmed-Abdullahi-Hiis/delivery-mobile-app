// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MyAuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   User? _user;
//   String _role = 'user';
//   bool _loading = true;

//   User? get user => _user;
//   String get role => _role;
//   bool get isAdmin => _role == 'admin';
//   bool get isLoading => _loading;
//   bool get isLoggedIn => _user != null; // ✅ Add this

//   MyAuthProvider() {
//     // Listen to auth state changes
//     _auth.authStateChanges().listen(_onAuthChanged);
//   }

//   /// 🔁 Handle login/logout and Firestore role loading
//   Future<void> _onAuthChanged(User? firebaseUser) async {
//     _user = firebaseUser;
//     _loading = true;
//     notifyListeners();

//     if (firebaseUser == null) {
//       _role = 'user';
//       _loading = false;
//       notifyListeners();
//       return;
//     }

//     final ref = _db.collection('users').doc(firebaseUser.uid);
//     final doc = await ref.get();

//     // Create user doc if it doesn't exist
//     if (!doc.exists) {
//       await ref.set({
//         'name': firebaseUser.displayName ?? '',
//         'email': firebaseUser.email ?? '',
//         'role': 'user',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       _role = 'user';
//     } else {
//       _role = doc.data()?['role'] ?? 'user';
//     }

//     _loading = false;
//     notifyListeners();
//   }

//   /// 👤 Update profile info (name + email)
//   Future<void> updateProfile({String? name, String? email}) async {
//     if (_user == null) return;

//     try {
//       if (name != null && name.isNotEmpty) {
//         await _user!.updateDisplayName(name);
//         await _db.collection('users').doc(_user!.uid).update({
//           'name': name,
//         });
//       }

//       if (email != null && email.isNotEmpty && email != _user!.email) {
//         try {
//           await _user!.updateEmail(email);
//           await _db.collection('users').doc(_user!.uid).update({
//             'email': email,
//           });
//         } on FirebaseAuthException catch (e) {
//           if (e.code == 'requires-recent-login') {
//             throw Exception(
//                 'Please re-login and try again to update your email.');
//           } else {
//             throw Exception('Failed to update email: ${e.message}');
//           }
//         }
//       }

//       await _user!.reload();
//       _user = _auth.currentUser;
//       notifyListeners();
//     } catch (e) {
//       throw Exception('Failed to update profile: $e');
//     }
//   }

//   /// 🔐 Manually reload role from Firestore (optional)
//   Future<void> loadUserRole() async {
//     if (_user == null) return;

//     _loading = true;
//     notifyListeners();

//     final ref = _db.collection('users').doc(_user!.uid);
//     final doc = await ref.get();

//     _role = doc.data()?['role'] ?? 'user';
//     _loading = false;
//     notifyListeners();
//   }

//   /// 🚪 Logout
//   Future<void> logout() async {
//     await _auth.signOut();
//     _user = null;
//     _role = 'user';
//     notifyListeners();
//   }
// }





import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? user;
  String role = 'user';
  bool isLoading = true;

  bool get isAdmin => role == 'admin';
  bool get isLoggedIn => user != null;

  MyAuthProvider() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  /// 🔁 Handle login / logout automatically
  Future<void> _onAuthChanged(User? firebaseUser) async {
    isLoading = true;
    notifyListeners();

    user = firebaseUser;

    if (firebaseUser == null) {
      role = 'user';
      isLoading = false;
      notifyListeners();
      return;
    }

    await _loadUser(firebaseUser.uid);
  }

  /// 🔄 Used after login / register
  Future<void> reloadUser() async {
    isLoading = true;
    notifyListeners();

    user = _auth.currentUser;

    if (user == null) {
      role = 'user';
      isLoading = false;
      notifyListeners();
      return;
    }

    await _loadUser(user!.uid);
  }

  /// 📥 Load or auto-create Firestore user document
  Future<void> _loadUser(String uid) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'email': user?.email ?? '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      role = 'user';
    } else {
      role = snap.data()?['role'] ?? 'user';
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✏️ Update profile (name & email)
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      if (name.isNotEmpty) {
        await user!.updateDisplayName(name);
        await _db.collection('users').doc(user!.uid).update({'name': name});
      }

      if (email.isNotEmpty && email != user!.email) {
        await user!.updateEmail(email);
        await _db.collection('users').doc(user!.uid).update({'email': email});
      }

      await user!.reload();
      user = _auth.currentUser;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    role = 'user';
    notifyListeners();
  }
}
