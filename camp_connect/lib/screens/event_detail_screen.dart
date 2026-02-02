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
    final bool isCancelled = event['status'] == 'cancelled';

    final bool shouldDim = isPast || isCancelled;
    final String eventId = event['id'];

    late String statusText;
    late Color badgeColor;
    late Color textColor;

    // ================= STATUS LOGIC =================
    if (isCancelled) {
      statusText = 'Cancelled';
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else if (isPast) {
      statusText = 'Event Ended';
      badgeColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
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
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Opacity(
          opacity: shouldDim ? 0.75 : 1,
          child: AppBar(
            title: const Text('Event Details'),
            elevation: shouldDim ? 0 : 1,
            backgroundColor: shouldDim ? Colors.grey.shade200 : null,
            foregroundColor: shouldDim ? Colors.black54 : null,
          ),
        ),
      ),

      // ================= BODY =================
      body: Opacity(
        opacity: shouldDim ? 0.6 : 1,
        child: Center(
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
                        // ================= TITLE =================
                        Text(
                          event['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ================= DATE =================
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(formatDate(event['date'])),

                            const Spacer(),

                            Row(
                              children: [
                                Icon(
                                  event['status'] == 'cancelled'
                                      ? Icons.cancel_outlined
                                      : event['updatedAt'] != null
                                      ? Icons.edit_outlined
                                      : Icons.schedule_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event['status'] == 'cancelled'
                                      ? 'Cancelled on ${formatDate(event['cancelledAt'])}'
                                      : event['updatedAt'] != null
                                      ? 'Updated on ${formatDate(event['updatedAt'])}'
                                      : 'Created on ${formatDate(event['createdAt'])}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ================= LOCATION =================
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(event['location'])),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ================= STATUS BADGE =================
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

                        // ================= DESCRIPTION =================
                        Text(
                          event['description'] ?? 'No description available.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= REGISTER BUTTON =================
                if (!isPast && !isCancelled)
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
                                    await RegistrationService()
                                        .registerForEvent(eventId);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registered successfully',
                                        ),
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
                              side: BorderSide(
                                color: textColor.withAlpha((0.4 * 255).toInt()),
                              ),
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
      ),
    );
  }
}
