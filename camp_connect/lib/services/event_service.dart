import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= HELPERS =================
  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ================= STREAM EVENTS =================
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
          'status': data['status'] ?? 'active',
          'createdBy': data['createdBy'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
          'cancelledAt': (data['cancelledAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }

  // ================= CREATE EVENT =================
  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime date,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.data()?['role'] != 'admin') {
      throw Exception('Unauthorized');
    }

    await _firestore.collection('events').add({
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': 'active',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= UPDATE EVENT =================
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String location,
    required DateTime date,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }

    // 🔐 ADMIN CHECK
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.data()?['role'] != 'admin') {
      throw Exception('Only admins can edit events');
    }

    final ref = _firestore.collection('events').doc(eventId);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      throw Exception('Event not found');
    }

    final data = snapshot.data()!;
    final eventDate = _normalizeDate((data['date'] as Timestamp).toDate());
    final today = _todayDate();

    // 🔒 OWNER CHECK
    if (data['createdBy'] != uid) {
      throw Exception('You can only edit your own events');
    }

    // 🚫 CANCELLED EVENTS
    if (data['status'] == 'cancelled') {
      throw Exception('Cancelled events cannot be updated');
    }

    // 🚫 PAST EVENTS
    if (eventDate.isBefore(today)) {
      throw Exception('Ended events cannot be updated');
    }

    await ref.update({
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= CANCEL EVENT =================
  Future<void> cancelEvent(String eventId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }

    // 🔐 ADMIN CHECK
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.data()?['role'] != 'admin') {
      throw Exception('Only admins can cancel events');
    }

    final ref = _firestore.collection('events').doc(eventId);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      throw Exception('Event not found');
    }

    final data = snapshot.data()!;
    final eventDate = _normalizeDate((data['date'] as Timestamp).toDate());
    final today = _todayDate();

    // 🔒 OWNER CHECK
    if (data['createdBy'] != uid) {
      throw Exception('You can only cancel your own events');
    }

    // 🚫 DOUBLE CANCEL
    if (data['status'] == 'cancelled') {
      throw Exception('Event already cancelled');
    }

    // 🚫 PAST EVENTS
    if (eventDate.isBefore(today)) {
      throw Exception('Ended events cannot be cancelled');
    }

    await ref.update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}
