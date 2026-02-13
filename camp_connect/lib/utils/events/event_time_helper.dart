import 'package:cloud_firestore/cloud_firestore.dart';

// ================= EVENT TIME HELPER =================

class EventTimeHelper {
  static DateTime buildEndDateTimeFromData(Map<String, dynamic> data) {
    final DateTime date = (data['date'] as Timestamp).toDate();

    final parts = data['endTime'].split(':');

    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static bool isEventClosed(Map<String, dynamic> data) {
    final end = buildEndDateTimeFromData(data);

    return DateTime.now().isAfter(end);
  }
}
