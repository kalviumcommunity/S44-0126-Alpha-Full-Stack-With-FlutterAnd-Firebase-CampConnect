import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class EventCard extends StatelessWidget {
  final Map<String, String> event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final eventDate = parseDate(event['date']!);
    final today = todayDate();

    final isPast = eventDate.isBefore(today);
    final isToday =
        eventDate.year == today.year &&
        eventDate.month == today.month &&
        eventDate.day == today.day;

    String statusText;
    Color badgeColor;
    Color badgeTextColor;

    if (isPast) {
      statusText = 'Event Ended';
      badgeColor = Colors.red.shade100;
      badgeTextColor = Colors.red.shade800;
    } else if (isToday) {
      statusText = 'Event Today';
      badgeColor = Colors.orange.shade100;
      badgeTextColor = Colors.orange.shade800;
    } else {
      statusText = 'Upcoming Event';
      badgeColor = Colors.green.shade100;
      badgeTextColor = Colors.green.shade800;
    }

    return Card(
      elevation: isPast ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isPast ? Colors.grey.shade100 : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // ✅ even past events open details
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Title
                    Text(
                      event['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPast ? Colors.black54 : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📅 Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isPast ? Colors.grey : Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(event['date']!),
                          style: TextStyle(
                            fontSize: 14,
                            color: isPast ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 📍 Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: isPast ? Colors.grey : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event['location']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isPast ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Status badge (always visible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ➡ Chevron (muted for past)
              Icon(
                Icons.chevron_right,
                color: isPast ? Colors.grey : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
