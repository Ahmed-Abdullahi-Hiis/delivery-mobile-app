

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

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Old stable API
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  /// 🔵 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;
    final uid = user.uid;

    // 🔥 Create Firestore user if not exists
    final doc = await _db.collection("users").doc(uid).get();

    if (!doc.exists) {
      await _db.collection("users").doc(uid).set({
        "uid": uid,
        "name": user.displayName ?? "No Name",
        "email": user.email,
        "image": user.photoURL ?? "",
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });
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
