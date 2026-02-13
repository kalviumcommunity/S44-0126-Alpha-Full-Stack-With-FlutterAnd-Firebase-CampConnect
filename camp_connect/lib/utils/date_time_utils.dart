import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= DATE UTILITIES =================

/// Returns today's date without time (00:00:00)
DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Removes time from a DateTime
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Safely parse Firestore date
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;

  if (value is Timestamp) return value.toDate();

  return null;
}

/// Formats date as: 12 Jan 2026
String formatDate(dynamic date) {
  final parsed = _parseDate(date);

  if (parsed == null) return 'Invalid date';

  return DateFormat('dd MMM yyyy').format(parsed);
}

/// Formats time string (HH:mm → hh:mm AM/PM)
String formatTime(String time) {
  try {
    final parsed = DateFormat('HH:mm').parse(time);
    return DateFormat('hh:mm a').format(parsed);
  } catch (_) {
    return time;
  }
}

/// Formats time range
String formatTimeRange(String? start, String? end) {
  if (start == null || end == null || start.isEmpty || end.isEmpty) {
    return 'Time not set';
  }

  final formattedStart = formatTime(start);
  final formattedEnd = formatTime(end);

  return '$formattedStart - $formattedEnd';
}

/// Combines date + HH:mm time into DateTime
DateTime combineDateAndTime(DateTime date, String? time) {
  final safeTime = time?.isNotEmpty == true ? time! : '00:00';

  try {
    final parsed = DateFormat('HH:mm').parse(safeTime);

    return DateTime(
      date.year,
      date.month,
      date.day,
      parsed.hour,
      parsed.minute,
    );
  } catch (_) {
    return DateTime(date.year, date.month, date.day);
  }
}

// ================= EVENT DATETIME HELPERS =================

/// Event START datetime
DateTime getEventStartDateTime(Map<String, dynamic> event) {
  final date = _parseDate(event['date']);

  if (date == null) {
    return DateTime.now(); // safe fallback
  }

  final String? startTime = event['startTime'];

  return combineDateAndTime(date, startTime);
}

/// Event END datetime
DateTime getEventEndDateTime(Map<String, dynamic> event) {
  final date = _parseDate(event['date']);

  if (date == null) {
    return DateTime.now();
  }

  final String? endTime = event['endTime'];

  return combineDateAndTime(date, endTime);
}

/// Returns true if event is ended
bool isEventEnded(Map<String, dynamic> event) {
  final end = getEventEndDateTime(event);
  return DateTime.now().isAfter(end);
}

/// Returns true if event is ongoing
bool isEventOngoing(Map<String, dynamic> event) {
  final now = DateTime.now();

  final start = getEventStartDateTime(event);
  final end = getEventEndDateTime(event);

  return now.isAfter(start) && now.isBefore(end);
}

/// Returns true if event is upcoming
bool isEventUpcoming(Map<String, dynamic> event) {
  final start = getEventStartDateTime(event);
  return DateTime.now().isBefore(start);
}
