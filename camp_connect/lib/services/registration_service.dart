import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationService {
  static final RegistrationService _instance = RegistrationService._internal();
  factory RegistrationService() => _instance;
  RegistrationService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> isRegistered(String eventId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> registerForEvent(String eventId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final alreadyRegistered = await isRegistered(eventId);
    if (alreadyRegistered) return;

    await _firestore.collection('registrations').add({
      'eventId': eventId,
      'userId': uid,
      'registeredAt': Timestamp.now(),
    });
  }

  Stream<List<String>> streamUserRegistrations() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => d['eventId'] as String).toList(),
        );
  }
}
