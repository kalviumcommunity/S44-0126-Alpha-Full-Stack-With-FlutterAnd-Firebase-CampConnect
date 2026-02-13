import 'package:flutter/material.dart';

import '../services/event_service.dart';
import '../services/auth_service.dart';

import '../widgets/events/event_detail_body.dart';
import '../widgets/events/event_detail_bottom.dart';

import '../utils/date_time_utils.dart';

// ================= EVENT DETAIL =================

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final eventId = event['id'];

    return StreamBuilder<Map<String, dynamic>?>(
      stream: EventService().streamEvent(eventId),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Failed to load event')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final event = snapshot.data!;

        final bool isPast = isEventEnded(event);

        final status = event['status'] ?? 'active';

        final bool isCancelled = status == 'cancelled';

        final bool shouldDim = isPast || isCancelled;

        final currentUserId = AuthService().currentUser?.uid;

        final bool isOwnerAdmin =
            currentUserId != null && event['createdBy'] == currentUserId;

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            title: const Text('Event Details'),

            elevation: shouldDim ? 0 : 1,

            backgroundColor: shouldDim ? Colors.grey.shade200 : null,

            foregroundColor: shouldDim ? Colors.black87 : null,
          ),

          body: Opacity(
            opacity: shouldDim ? 0.6 : 1,

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),

                child: Column(
                  children: [
                    // ================= CONTENT =================
                    Expanded(child: EventDetailBody(event: event)),

                    // ================= BOTTOM =================
                    EventDetailBottom(
                      eventId: eventId,
                      event: event,
                      isOwnerAdmin: isOwnerAdmin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
