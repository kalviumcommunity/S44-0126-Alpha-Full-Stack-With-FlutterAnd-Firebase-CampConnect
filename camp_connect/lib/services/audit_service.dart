import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> log({
    required String action,
    required String resourceId,
    String status = 'success',
    String? message,
  }) async {
    final user = _auth.currentUser;

    String? role;

    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      role = userDoc.data()?['role'];
    }

    await _firestore.collection('audit_logs').add({
      'userId': user?.uid,
      'userEmail': user?.email,
      'userRole': role,
      'action': action,
      'resourceId': resourceId,
      'status': status,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
