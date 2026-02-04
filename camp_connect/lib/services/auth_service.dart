import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= AUTH SERVICE =================

class AuthService {
  // ================= SINGLETON =================

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  // ================= FIREBASE =================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= GETTERS =================

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= SIGNUP =================

  /// Secure signup (role enforced as student)
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

          // 🔒 Enforced default role
          'role': 'student',

          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      return null;
    }
  }

  // ================= LOGIN =================

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

  // ================= LOGOUT =================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================= USER PROFILE =================

  Stream<Map<String, dynamic>?> streamUserProfile() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;

      return doc.data();
    });
  }

  // ================= ROLE CHECK =================

  /// One-time admin check
  Future<bool> isAdmin() async {
    final uid = currentUserId;

    if (uid == null) return false;

    final doc = await _firestore.collection('users').doc(uid).get();

    return doc.data()?['role'] == 'admin';
  }

  /// Live admin status stream
  Stream<bool> isAdminStream() {
    return streamUserProfile().map((data) {
      return data?['role'] == 'admin';
    });
  }
}
