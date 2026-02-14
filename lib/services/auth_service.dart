

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   /// 🔐 LOGIN
//   Future<void> login(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   /// 📝 REGISTER (THIS WAS MISSING ❌)
//   Future<void> register({
//     required String name,
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     final cred = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     // Create Firestore user document
//     await _db.collection('users').doc(cred.user!.uid).set({
//       'name': name,
//       'email': email,
//       'role': role,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// 🔁 PASSWORD RESET
//   Future<void> sendPasswordReset(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }

//   /// 🚪 LOGOUT
//   Future<void> logout() async {
//     await _auth.signOut();
//   }
// }




import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ GoogleSignIn (works on all platforms)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 🔐 LOGIN (EMAIL)
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 📝 REGISTER (EMAIL)
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String image = "",
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔵 GOOGLE SIGN-IN (Works on all platforms)
  Future<void> signInWithGoogle() async {
    print('🔵 Google Sign-In starting...');
    print('⏱️ If popup doesn\'t appear, check your browser\'s popup blocker');
    
    try {
      // Add a slight delay to ensure everything is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('🔵 Attempting to open Google Sign-In popup...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏱️ Google Sign-In timeout - popup may have been blocked');
              throw TimeoutException('Google Sign-In popup timeout');
            },
          );
      
      if (googleUser == null) {
        print('⚠️ User cancelled Google sign-in or popup was blocked');
        throw Exception('Google sign-in cancelled. Check if popups are blocked.');
      }
      
      print('✅ Google user signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('✅ Google authentication obtained');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✅ Firebase credential created, signing in...');

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;
      final uid = user.uid;

      print('✅ Firebase authentication successful: $uid');

      // 🔥 Create Firestore user if not exists
      final doc = await _db.collection("users").doc(uid).get();

      if (!doc.exists) {
        print('📝 Creating new user in Firestore...');
        await _db.collection("users").doc(uid).set({
          "uid": uid,
          "name": user.displayName ?? "No Name",
          "email": user.email,
          "image": user.photoURL ?? "",
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
        print('✅ User created in Firestore');
      } else {
        print('✅ User already exists in Firestore');
      }
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  /// 🔁 PASSWORD RESET
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
