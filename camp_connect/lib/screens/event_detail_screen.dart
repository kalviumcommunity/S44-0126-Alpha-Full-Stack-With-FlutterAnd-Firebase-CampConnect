import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../services/registration_service.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final DateTime eventDate = normalizeDate(event['date']);
    final DateTime today = todayDate();

    final bool isPast = eventDate.isBefore(today);
    final bool isToday = eventDate.isAtSameMomentAs(today);
    final String eventId = event['id'];

    late String statusText;
    late Color badgeColor;
    late Color textColor;

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
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
                          Text(formatDate(event['date'])),
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
                          Expanded(child: Text(event['location'])),
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
                      const Divider(),
                      const SizedBox(height: 12),

                      Text(
                        event['description'] ?? 'No description available.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: isPast ? Colors.black54 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 REAL REGISTER BUTTON
              if (!isPast)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: SizedBox(
                    width: size.width > 720 ? 400 : double.infinity,
                    height: 52,
                    child: StreamBuilder<List<String>>(
                      stream: RegistrationService().streamUserRegistrations(),
                      builder: (context, snapshot) {
                        final isRegistered =
                            snapshot.hasData &&
                            snapshot.data!.contains(eventId);

                        return OutlinedButton(
                          onPressed: isRegistered
                              ? null
                              : () async {
                                  await RegistrationService().registerForEvent(
                                    eventId,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registered successfully'),
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isRegistered
                                ? Colors.grey.shade200
                                : badgeColor,
                            foregroundColor: isRegistered
                                ? Colors.grey
                                : textColor,
                            side: BorderSide(color: textColor.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            isRegistered ? 'Registered' : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
