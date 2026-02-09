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

  // ================= CHECK REGISTRATION =================

  Future<bool> isRegistered(String eventId) async {
    final uid = currentUserId;

    if (uid == null) return false;

    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  // ================= REGISTER =================

  Future<void> registerForEvent(String eventId) async {
    final uid = currentUserId;

    if (uid == null) return;

    final alreadyRegistered = await isRegistered(eventId);

    if (alreadyRegistered) return;

    await _firestore.collection('registrations').add({
      'eventId': eventId,
      'userId': uid,
      'attended': false,
      'registeredAt': Timestamp.now(),
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
