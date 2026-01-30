import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, String> event;

  const EventDetailScreen({super.key, required this.event});

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
    Color textColor;

    if (isPast) {
      statusText = 'Event Ended';
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else if (isToday) {
      statusText = 'Event Today';
      badgeColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else {
      statusText = 'Upcoming Event';
      badgeColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    }

    return Scaffold(
      backgroundColor: isPast ? Colors.grey.shade50 : Colors.white,

      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: isPast ? Colors.grey.shade200 : null,
        foregroundColor: isPast ? Colors.black54 : null,
        elevation: isPast ? 0 : 1,
      ),

      body: Column(
        children: [
          // 🔹 Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isPast ? Colors.black54 : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

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
                          fontSize: 15,
                          color: isPast ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

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
                          style: TextStyle(
                            fontSize: 15,
                            color: isPast ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: isPast ? Colors.grey.shade300 : null),
                  const SizedBox(height: 12),

                  Text(
                    event['description'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isPast ? Colors.black54 : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 🔹 Bottom CTA (only if NOT past)
          if (!isPast)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const Text(
                                'Registrations Coming Soon',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'You’ll be able to register for events in the next version of CampConnect.',
                                style: TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  child: const Text('Got it'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: badgeColor,
                    foregroundColor: textColor,
                    side: BorderSide(color: textColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
