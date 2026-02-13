import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= REGISTRATION SERVICE =================

class RegistrationService {
  // ================= SINGLETON =================

  static final RegistrationService _instance = RegistrationService._internal();

  factory RegistrationService() => _instance;

  RegistrationService._internal();

  // ================= FIREBASE =================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= GETTERS =================

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= AUTH GUARD =================

  String _requireUser() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User not authenticated');
    }

    return uid;
  }

  // ================= BASE QUERY =================

  Query<Map<String, dynamic>> _userEventQuery({
    required String eventId,
    required String userId,
  }) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1);
  }

  // ================= CHECK REGISTRATION =================

  Future<bool> isRegistered(String eventId) async {
    final uid = currentUserId;

    if (uid == null) return false;

    final snapshot = await _userEventQuery(eventId: eventId, userId: uid).get();

    return snapshot.docs.isNotEmpty;
  }

  // ================= REGISTER (SAFE) =================

  Future<void> registerForEvent(String eventId) async {
    final uid = _requireUser();

    final registrationsRef = _firestore.collection('registrations');

    await _firestore.runTransaction((transaction) async {
      final querySnapshot = await registrationsRef
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Already registered');
      }

      final newDoc = registrationsRef.doc();

      transaction.set(newDoc, {
        'eventId': eventId,
        'userId': uid,
        'attended': false,
        'registeredAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ================= STREAM USER REGISTRATIONS =================

  Stream<List<String>> streamUserRegistrations() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc['eventId'] as String).toList();
        });
  }
}
