import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // 🔐 Secure signup (role enforced)
  Future<User?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': 'student', // 🔒 enforced
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 User profile
  Stream<Map<String, dynamic>?> streamUserProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  // 🔹 Role check
  Future<bool> isAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  }

  // ✅ Admin role
  Stream<bool> isAdminStream() {
    return streamUserProfile().map((data) {
      return data?['role'] == 'admin';
    });
  }
}
