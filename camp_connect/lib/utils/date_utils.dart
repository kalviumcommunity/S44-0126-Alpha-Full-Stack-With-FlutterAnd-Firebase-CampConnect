import 'package:intl/intl.dart';

DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}
