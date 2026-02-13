import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

// ================= EVENT META HELPER =================

class EventMetaHelper {
  static DateTime? _parse(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    try {
      return value.toDate(); // Timestamp
    } catch (_) {
      return null;
    }
  }

  static ({String text, IconData icon}) resolve(Map<String, dynamic> event) {
    final cancelledAt = _parse(event['cancelledAt']);
    final completedAt = _parse(event['completedAt']);
    final updatedAt = _parse(event['updatedAt']);
    final createdAt = _parse(event['createdAt']);

    if (event['status'] == 'cancelled' && cancelledAt != null) {
      return (
        text: 'Cancelled on ${formatDate(cancelledAt)}',
        icon: Icons.cancel_outlined,
      );
    }

    if (event['status'] == 'completed' && completedAt != null) {
      return (
        text: 'Completed on ${formatDate(completedAt)}',
        icon: Icons.check_circle_outline,
      );
    }

    if (updatedAt != null) {
      return (
        text: 'Updated on ${formatDate(updatedAt)}',
        icon: Icons.edit_outlined,
      );
    }

    if (createdAt != null) {
      return (
        text: 'Created on ${formatDate(createdAt)}',
        icon: Icons.schedule_outlined,
      );
    }

    return (text: 'Event created', icon: Icons.schedule_outlined);
  }
}
