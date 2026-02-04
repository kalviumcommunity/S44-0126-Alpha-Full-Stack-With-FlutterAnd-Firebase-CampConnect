import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= EVENT SERVICE =================

class EventService {
  // ================= SINGLETON =================

  static final EventService _instance = EventService._internal();

  factory EventService() => _instance;

  EventService._internal();

  // ================= FIREBASE =================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= GETTERS =================

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= HELPERS =================

  DateTime _normalizeDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  DateTime _todayDate() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  // ================= AUTH CHECK =================

  Future<void> _requireAdmin() async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Not authenticated');
    }

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.data()?['role'] != 'admin') {
      throw Exception('Admin access required');
    }
  }

  Future<Map<String, dynamic>> _getEvent(String eventId) async {
    final snap = await _firestore.collection('events').doc(eventId).get();

    if (!snap.exists) {
      throw Exception('Event not found');
    }

    return snap.data()!;
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

          'completedAt': (data['completedAt'] as Timestamp?)?.toDate(),
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
    await _requireAdmin();

    final uid = currentUserId!;

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
    await _requireAdmin();

    final uid = currentUserId!;

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    final eventDate = _normalizeDate((data['date'] as Timestamp).toDate());

    final today = _todayDate();

    // ================= VALIDATION =================

    if (data['createdBy'] != uid) {
      throw Exception('Only creator can edit event');
    }

    if (data['status'] == 'cancelled' || data['status'] == 'completed') {
      throw Exception('Closed events cannot be edited');
    }

    if (eventDate.isBefore(today)) {
      throw Exception('Past events cannot be edited');
    }

    // ================= UPDATE =================

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
    await _requireAdmin();

    final uid = currentUserId!;

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    final eventDate = _normalizeDate((data['date'] as Timestamp).toDate());

    final today = _todayDate();

    // ================= VALIDATION =================

    if (data['createdBy'] != uid) {
      throw Exception('Only creator can cancel event');
    }

    if (data['status'] == 'cancelled') {
      throw Exception('Event already cancelled');
    }

    if (data['status'] == 'completed') {
      throw Exception('Completed event cannot be cancelled');
    }

    if (eventDate.isBefore(today)) {
      throw Exception('Past events cannot be cancelled');
    }

    // ================= UPDATE =================

    await ref.update({
      'status': 'cancelled',

      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= COMPLETE EVENT =================

  Future<void> completeEvent(String eventId) async {
    await _requireAdmin();

    final uid = currentUserId!;

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    // ================= VALIDATION =================

    if (data['createdBy'] != uid) {
      throw Exception('Only creator can complete event');
    }

    if (data['status'] == 'cancelled') {
      throw Exception('Cancelled event cannot be completed');
    }

    if (data['status'] == 'completed') {
      throw Exception('Event already completed');
    }

    // ================= UPDATE =================

    await ref.update({
      'status': 'completed',

      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= STREAM REGISTRATIONS =================

  Stream<List<Map<String, dynamic>>> streamRegistrationsForEvent(
    String eventId,
  ) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,

              'userId': data['userId'],
              'eventId': data['eventId'],

              'registeredAt': (data['registeredAt'] as Timestamp).toDate(),

              'attended': data['attended'] ?? false,

              'markedBy': data['markedBy'],

              'markedAt': (data['markedAt'] as Timestamp?)?.toDate(),
            };
          }).toList();
        });
  }

  // ================= MARK ATTENDANCE =================

  Future<void> markAttendance({
    required String registrationId,
    required bool attended,
  }) async {
    await _requireAdmin();

    final uid = currentUserId!;

    // ================= REGISTRATION =================

    if (registrationId.isEmpty) {
      throw Exception('Invalid request');
    }

    final regRef = _firestore.collection('registrations').doc(registrationId);

    final regSnap = await regRef.get();

    if (!regSnap.exists) {
      throw Exception('Registration not found');
    }

    final regData = regSnap.data()!;
    final eventId = regData['eventId'];

    // ================= EVENT =================

    final eventData = await _getEvent(eventId);

    // ================= VALIDATION =================

    if (eventData['createdBy'] != uid) {
      throw Exception('Unauthorized');
    }

    if (eventData['status'] == 'cancelled' ||
        eventData['status'] == 'completed') {
      throw Exception('Event closed');
    }

    // ================= UPDATE =================

    await regRef.update({
      'attended': attended,
      'markedBy': uid,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ATTENDANCE STATS =================

  Future<Map<String, int>> getAttendanceStats(String eventId) async {
    await _requireAdmin();

    final uid = currentUserId!;

    final event = await _getEvent(eventId);

    if (event['createdBy'] != uid) {
      throw Exception('Unauthorized');
    }

    final snapshot = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .get();

    int registered = snapshot.docs.length;
    int attended = 0;

    for (final doc in snapshot.docs) {
      if (doc['attended'] == true) {
        attended++;
      }
    }

    return {'registered': registered, 'attended': attended};
  }
}
