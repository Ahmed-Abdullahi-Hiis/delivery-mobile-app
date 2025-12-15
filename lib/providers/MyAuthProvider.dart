import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAuthProvider extends ChangeNotifier { // <- rename class
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
