import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Records an audit log
  static Future<void> log({
    required String action,
    required String resourceType,
    required String resourceId,

    String? targetUserId,
    String status = 'success',
  }) async {
    final uid = _auth.currentUser?.uid;

    await _firestore.collection('audit_logs').add({
      // Who did it
      'actorUserId': uid,

      // What
      'action': action,

      // On what
      'resourceType': resourceType,
      'resourceId': resourceId,

      // On whom
      'targetUserId': targetUserId,

      // Meta
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
