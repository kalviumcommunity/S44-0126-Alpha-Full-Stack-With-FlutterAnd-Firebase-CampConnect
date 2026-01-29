import 'package:intl/intl.dart';

DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime parseDate(String date) {
  final parsed = DateTime.parse(date);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

String formatDate(String date) {
  return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
}
