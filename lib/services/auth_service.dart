import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register new user with role
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    // 1️⃣ Create user in Firebase Auth
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2️⃣ Save additional info to Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3️⃣ Update Firebase user display name
    await cred.user!.updateDisplayName(name);

    return cred;
  }

  // Login existing user
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Forgot password
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}
