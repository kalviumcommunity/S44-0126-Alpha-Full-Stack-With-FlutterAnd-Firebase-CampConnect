import 'package:flutter/material.dart';

import 'date_time_utils.dart';

// ================= STATUS INFO =================

class EventStatusInfo {
  final String text;
  final Color badgeColor;
  final Color textColor;

  final bool isPast;
  final bool isOngoing;
  final bool isCancelled;
  final bool isCompleted;

  const EventStatusInfo({
    required this.text,
    required this.badgeColor,
    required this.textColor,
    required this.isPast,
    required this.isOngoing,
    required this.isCancelled,
    required this.isCompleted,
  });
}

// ================= RESOLVER =================

class EventStatusHelper {
  static EventStatusInfo resolve(Map<String, dynamic> event) {
    final bool isPast = isEventEnded(event);
    final bool isOngoing = isEventOngoing(event);

    final DateTime startDate = normalizeDate(getEventStartDateTime(event));

    final bool isToday = startDate == todayDate();

    final String status = event['status'] ?? 'active';

    final bool isCancelled = status == 'cancelled';
    final bool isCompleted = status == 'completed';

    // Priority based resolution

    if (isCancelled) {
      return EventStatusInfo(
        text: 'Cancelled',
        badgeColor: Colors.red.shade100,
        textColor: Colors.red.shade800,
        isPast: isPast,
        isOngoing: isOngoing,
        isCancelled: true,
        isCompleted: false,
      );
    }

    if (isPast) {
      return EventStatusInfo(
        text: 'Event Ended',
        badgeColor: Colors.grey.shade300,
        textColor: Colors.grey.shade700,
        isPast: true,
        isOngoing: false,
        isCancelled: false,
        isCompleted: false,
      );
    }

    if (isCompleted) {
      return EventStatusInfo(
        text: 'Completed',
        badgeColor: Colors.deepPurple.shade100,
        textColor: Colors.deepPurple.shade800,
        isPast: false,
        isOngoing: false,
        isCancelled: false,
        isCompleted: true,
      );
    }

    if (isOngoing) {
      return EventStatusInfo(
        text: 'Ongoing',
        badgeColor: Colors.blue.shade100,
        textColor: Colors.blue.shade800,
        isPast: false,
        isOngoing: true,
        isCancelled: false,
        isCompleted: false,
      );
    }

    if (isToday) {
      return EventStatusInfo(
        text: 'Event Today',
        badgeColor: Colors.orange.shade100,
        textColor: Colors.orange.shade800,
        isPast: false,
        isOngoing: false,
        isCancelled: false,
        isCompleted: false,
      );
    }

    return EventStatusInfo(
      text: 'Upcoming Event',
      badgeColor: Colors.green.shade100,
      textColor: Colors.green.shade800,
      isPast: false,
      isOngoing: false,
      isCancelled: false,
      isCompleted: false,
    );
  }
}
