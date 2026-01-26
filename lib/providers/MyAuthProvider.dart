


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
