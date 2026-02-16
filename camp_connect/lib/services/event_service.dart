import 'package:camp_connect/services/audit_service.dart';
import 'package:camp_connect/utils/events/event_mapper.dart';
import 'package:camp_connect/utils/events/event_time_helper.dart';
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

  // ================= AUTH GUARDS =================

  String _requireUser() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User not authenticated');
    }

    return uid;
  }

  Future<void> _requireAdmin() async {
    final uid = _requireUser();

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.data()?['role'] != 'admin') {
      throw Exception('Admin access required');
    }
  }

  // ================= GET EVENT =================

  Future<Map<String, dynamic>> _getEvent(String eventId) async {
    final snap = await _firestore.collection('events').doc(eventId).get();

    if (!snap.exists || snap.data() == null) {
      throw Exception('Event not found');
    }

    return snap.data()!;
  }

  // ================= STREAM SINGLE =================

  Stream<Map<String, dynamic>?> streamEvent(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;

      return EventMapper.fromEventDoc(doc);
    });
  }

  // ================= STREAM ALL =================

  Stream<List<Map<String, dynamic>>> streamEvents() {
    return _firestore.collection('events').orderBy('date').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map(EventMapper.fromEventDoc).toList();
    });
  }

  // ================= PREPARE DATA =================

  Map<String, dynamic> _prepareEventData({
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    _validateTimeRange(startTime, endTime);

    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // ================= CREATE =================

  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    await _requireAdmin();

    final uid = _requireUser();

    final data = _prepareEventData(
      title: title,
      description: description,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );

    final ref = await _firestore.collection('events').add({
      ...data,
      'status': 'active',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      action: 'create_event',
      resourceType: 'event',
      resourceId: ref.id,
      targetUserId: uid,
    );
  }

  // ================= UPDATE =================

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    await _requireAdmin();

    final uid = _requireUser();

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    // Time rule
    if (EventTimeHelper.isEventClosed(data)) {
      throw Exception('Past events cannot be edited');
    }

    // Ownership
    if (data['createdBy'] != uid) {
      throw Exception('Only creator can edit event');
    }

    // Status rule
    if (data['status'] == 'cancelled' || data['status'] == 'completed') {
      throw Exception('Closed events cannot be edited');
    }

    final newData = _prepareEventData(
      title: title,
      description: description,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );

    await ref.update({...newData, 'updatedAt': FieldValue.serverTimestamp()});

    await AuditService.log(
      action: 'update_event',
      resourceType: 'event',
      resourceId: eventId,
      targetUserId: uid,
    );
  }

  // ================= CANCEL =================

  Future<void> cancelEvent(String eventId) async {
    await _requireAdmin();

    final uid = _requireUser();

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    if (EventTimeHelper.isEventClosed(data)) {
      throw Exception('Past events cannot be cancelled');
    }

    if (data['createdBy'] != uid) {
      throw Exception('Only creator can cancel event');
    }

    if (data['status'] == 'cancelled') {
      throw Exception('Event already cancelled');
    }

    if (data['status'] == 'completed') {
      throw Exception('Completed event cannot be cancelled');
    }

    await ref.update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      action: 'cancel_event',
      resourceType: 'event',
      resourceId: eventId,
      targetUserId: uid,
    );
  }

  // ================= COMPLETE =================

  Future<void> completeEvent(String eventId) async {
    await _requireAdmin();

    final uid = _requireUser();

    final ref = _firestore.collection('events').doc(eventId);

    final data = await _getEvent(eventId);

    if (EventTimeHelper.isEventClosed(data)) {
      throw Exception('Past events cannot be completed');
    }

    if (data['createdBy'] != uid) {
      throw Exception('Only creator can complete event');
    }

    if (data['status'] == 'cancelled') {
      throw Exception('Cancelled event cannot be completed');
    }

    if (data['status'] == 'completed') {
      throw Exception('Event already completed');
    }

    await ref.update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      action: 'complete_event',
      resourceType: 'event',
      resourceId: eventId,
      targetUserId: uid,
    );
  }

  // ================= REGISTRATIONS =================

  Stream<List<Map<String, dynamic>>> streamRegistrationsForEvent(
    String eventId,
  ) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(EventMapper.fromRegistrationDoc).toList();
        });
  }

  // ================= ATTENDANCE =================

  Future<void> markAttendance({
    required String registrationId,
    required bool attended,
  }) async {
    await _requireAdmin();

    final uid = _requireUser();

    final regRef = _firestore.collection('registrations').doc(registrationId);

    final regSnap = await regRef.get();

    if (!regSnap.exists || regSnap.data() == null) {
      throw Exception('Registration not found');
    }

    final regData = regSnap.data()!;

    final eventData = await _getEvent(regData['eventId']);

    if (eventData['createdBy'] != uid) {
      throw Exception('Unauthorized');
    }

    if (EventTimeHelper.isEventClosed(eventData)) {
      throw Exception('Attendance closed');
    }

    if (eventData['status'] == 'cancelled' ||
        eventData['status'] == 'completed') {
      throw Exception('Event closed');
    }

    await regRef.update({
      'attended': attended,
      'markedBy': uid,
      'markedAt': FieldValue.serverTimestamp(),
    });
    await AuditService.log(
      action: attended ? 'marked_present' : 'marked_absent',
      resourceType: 'registration',
      resourceId: registrationId,
      targetUserId: regData['userId'],
    );
  }

  // ================= STATS =================

  Future<Map<String, int>> getAttendanceStats(String eventId) async {
    await _requireAdmin();

    final uid = _requireUser();

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
      if (doc.data()['attended'] == true) {
        attended++;
      }
    }

    return {'registered': registered, 'attended': attended};
  }
}

// ================= TIME VALIDATION =================

void _validateTimeRange(String start, String end) {
  final regex = RegExp(r'^\d{2}:\d{2}$');

  if (!regex.hasMatch(start) || !regex.hasMatch(end)) {
    throw Exception('Invalid time format');
  }

  final startParts = start.split(':');
  final endParts = end.split(':');

  final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

  final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

  if (endMinutes <= startMinutes) {
    throw Exception('End time must be after start time');
  }
}
