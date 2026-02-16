import 'package:cloud_firestore/cloud_firestore.dart';

// ================= EVENT MAPPER =================

class EventMapper {
  // Event Document → Map

  static Map<String, dynamic> fromEventDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return {
      'id': doc.id,

      'title': data['title'] ?? '',
      'description': data['description'],
      'location': data['location'] ?? '',

      'date': (data['date'] as Timestamp?)?.toDate(),

      'startTime': data['startTime'] ?? '',
      'endTime': data['endTime'] ?? '',

      'status': data['status'] ?? 'active',

      'createdBy': data['createdBy'],

      'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),

      'cancelledAt': (data['cancelledAt'] as Timestamp?)?.toDate(),
      'completedAt': (data['completedAt'] as Timestamp?)?.toDate(),
    };
  }

  // Registration → Map

  static Map<String, dynamic> fromRegistrationDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return {
      'id': doc.id,

      'userId': data['userId'],
      'eventId': data['eventId'],

      'registeredAt': data['registeredAt'] is Timestamp
          ? (data['registeredAt'] as Timestamp).toDate()
          : null,

      'attended': data['attended'] ?? false,

      'markedBy': data['markedBy'],
      'markedAt': (data['markedAt'] as Timestamp?)?.toDate(),
    };
  }
}
