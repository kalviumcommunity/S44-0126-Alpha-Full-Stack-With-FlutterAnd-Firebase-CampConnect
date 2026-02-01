import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> isRegistered(String eventId) async {
    final uid = _auth.currentUser!.uid;

    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> registerForEvent(String eventId) async {
    final uid = _auth.currentUser!.uid;

    final alreadyRegistered = await isRegistered(eventId);
    if (alreadyRegistered) return;

    await _firestore.collection('registrations').add({
      'eventId': eventId,
      'userId': uid,
      'registeredAt': Timestamp.now(),
    });
  }

  Stream<List<String>> streamUserRegistrations() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc['eventId'] as String).toList();
        });
  }
}
