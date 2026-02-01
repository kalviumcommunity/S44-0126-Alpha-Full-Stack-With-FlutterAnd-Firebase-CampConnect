import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> streamEvents() {
    return _firestore.collection('events').orderBy('date').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'description': data['description'],
          'location': data['location'],
          'date': (data['date'] as Timestamp).toDate(),
          'createdBy': data['createdBy'],
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  // 🔐 ADMIN-ONLY EVENT CREATION
  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime date,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('events').add({
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
