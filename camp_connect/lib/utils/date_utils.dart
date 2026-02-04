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
