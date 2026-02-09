import 'package:intl/intl.dart';

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

/// Formats date as: 12 Jan 2026
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Formats time string (HH:mm → hh:mm AM/PM)
/// Example: "14:30" → "02:30 PM"
String formatTime(String time) {
  try {
    final parsed = DateFormat('HH:mm').parse(time);

    return DateFormat('hh:mm a').format(parsed);
  } catch (e) {
    return time; // fallback if invalid
  }
}

/// Formats time range
/// Example: "09:00", "11:30" → "09:00 AM - 11:30 AM"
String formatTimeRange(String startTime, String endTime) {
  return "${formatTime(startTime)} - ${formatTime(endTime)}";
}
