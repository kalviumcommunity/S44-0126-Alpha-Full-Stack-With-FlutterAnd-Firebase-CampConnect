import 'package:flutter/material.dart';

import '../utils/date_utils.dart';
import '../services/registration_service.dart';
import '../services/auth_service.dart';

import '../widgets/attendance_sheet.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ================= DATES =================

    final DateTime eventDate = normalizeDate(event['date']);
    final DateTime today = todayDate();

    final bool isPast = eventDate.isBefore(today);
    final bool isToday = eventDate.isAtSameMomentAs(today);

    // ================= STATUS =================

    final bool isCancelled = event['status'] == 'cancelled';
    final bool isCompletedStatus = event['status'] == 'completed';

    // Completed timestamp
    final DateTime? completedAt = event['completedAt'];

    // Normalize completed date
    final DateTime? completedDate = completedAt != null
        ? normalizeDate(completedAt)
        : null;

    // Completed AND old
    final bool isCompletedAndPast =
        isCompletedStatus &&
        completedDate != null &&
        completedDate.isBefore(today);

    // Recently completed
    final bool isCompleted = isCompletedStatus && !isCompletedAndPast;

    final bool shouldDim = isPast || isCancelled;

    final String eventId = event['id'];

    // ================= CURRENT USER =================

    final currentUserId = AuthService().currentUser?.uid;

    final bool isOwnerAdmin =
        currentUserId != null && event['createdBy'] == currentUserId;

    // ================= STATUS UI =================

    late String statusText;
    late Color badgeColor;
    late Color textColor;

    // Priority: Cancelled → Past → Completed → Today → Upcoming

    if (isCancelled) {
      statusText = 'Cancelled';
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    }
    // Past OR old completed → grey
    else if (isPast || isCompletedAndPast) {
      statusText = 'Event Ended';
      badgeColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    }
    // Recent completed → purple
    else if (isCompleted) {
      statusText = 'Completed';
      badgeColor = Colors.deepPurple.shade100;
      textColor = Colors.deepPurple.shade800;
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
      appBar: AppBar(
        title: const Text('Event Details'),
        elevation: shouldDim ? 0 : 1,

        backgroundColor: shouldDim ? Colors.grey.shade200 : null,

        foregroundColor: shouldDim ? Colors.black87 : null,
      ),

      // ================= BODY =================
      body: Opacity(
        opacity: shouldDim ? 0.6 : 1,

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),

            child: Column(
              children: [
                // ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // TITLE
                        Text(
                          event['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DATE
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),

                            const SizedBox(width: 8),

                            Text(formatDate(event['date'])),

                            const Spacer(),

                            // META
                            Row(
                              children: [
                                Icon(
                                  isCancelled
                                      ? Icons.cancel_outlined
                                      : isCompletedStatus
                                      ? Icons.check_circle_outline
                                      : event['updatedAt'] != null
                                      ? Icons.edit_outlined
                                      : Icons.schedule_outlined,

                                  size: 14,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  isCancelled
                                      ? 'Cancelled on ${formatDate(event['cancelledAt'])}'
                                      : isCompletedStatus &&
                                            event['completedAt'] != null
                                      ? 'Completed on ${formatDate(event['completedAt'])}'
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

                        const SizedBox(height: 8),

                        // LOCATION
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),

                            const SizedBox(width: 8),

                            Expanded(child: Text(event['location'])),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // STATUS BADGE
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
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // DESCRIPTION
                        Text(
                          event['description'] ?? 'No description available',

                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // ================= BOTTOM =================
                if (!isCancelled)
                  // ADMIN
                  if (isOwnerAdmin)
                    AttendanceSheet(
                      eventId: eventId,

                      // lock after completed OR past
                      isCompleted: isCompleted || isCompletedAndPast || isPast,
                    )
                  // USER
                  else if (!isPast && !isCompleted)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),

                      child: SizedBox(
                        width: size.width > 720 ? 400 : double.infinity,

                        height: 52,

                        child: StreamBuilder<List<String>>(
                          stream: RegistrationService()
                              .streamUserRegistrations(),

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

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                  color: textColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
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
