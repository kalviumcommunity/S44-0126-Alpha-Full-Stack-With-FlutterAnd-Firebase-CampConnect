import 'package:cloud_firestore/cloud_firestore.dart';

// ================= EVENT TIME HELPER =================

class EventTimeHelper {
  // Build END datetime from Firestore data
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

  // Build START datetime from Firestore data
  static DateTime buildStartDateTimeFromData(Map<String, dynamic> data) {
    final DateTime date = (data['date'] as Timestamp).toDate();

    final parts = data['startTime'].split(':');

    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // Check if event already ended
  static bool isEventClosed(Map<String, dynamic> data) {
    final end = buildEndDateTimeFromData(data);

    return DateTime.now().isAfter(end);
  }

  // Check if event is in the past (start time)
  static bool isEventInPast(Map<String, dynamic> data) {
    final start = buildStartDateTimeFromData(data);

    return start.isBefore(DateTime.now());
  }

  // Validate before create/update
  static void validateFutureEvent({
    required DateTime date,
    required String startTime,
  }) {
    final parts = startTime.split(':');

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    if (startDateTime.isBefore(DateTime.now())) {
      throw Exception('Event start time must be in the future');
    }
  }
}
