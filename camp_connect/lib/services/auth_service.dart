import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 CURRENT USER (for email, uid)
  User? get currentUser => _auth.currentUser;

  // 🔹 SIGN UP
  Future<User?> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': userData['name'],
          'email': email,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      developer.log(e.toString(), name: 'AuthService.signUp');
      return null;
    }
  }

  // 🔹 LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      developer.log(e.toString(), name: 'AuthService.login');
      return null;
    }
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 REAL-TIME USER PROFILE (Firestore)
  Stream<Map<String, dynamic>> streamUserProfile() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }
}
