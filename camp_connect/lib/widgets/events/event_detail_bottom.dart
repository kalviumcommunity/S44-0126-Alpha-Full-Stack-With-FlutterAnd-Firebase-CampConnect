import 'package:camp_connect/services/registration_service.dart';
import 'package:camp_connect/utils/event_status_helper.dart';
import 'package:flutter/material.dart';

import '../admin/admin_attendance_sheet.dart';
import 'event_register_button.dart';

// ================= EVENT DETAIL BOTTOM =================

class EventDetailBottom extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> event;
  final bool isOwnerAdmin;

  const EventDetailBottom({
    super.key,
    required this.eventId,
    required this.event,
    required this.isOwnerAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final status = EventStatusHelper.resolve(event);

    if (status.isCancelled) {
      return const SizedBox.shrink();
    }

    if (isOwnerAdmin) {
      return AttendanceSheet(
        eventId: eventId,
        isCompleted: status.isCompleted,
        isEnded: status.isPast,
      );
    }

    if (!status.isPast && !status.isCompleted) {
      return StreamBuilder<List<String>>(
        stream: RegistrationService().streamUserRegistrations(),

        builder: (context, snapshot) {
          final registeredIds = snapshot.data ?? [];

          final isRegistered = registeredIds.contains(eventId);

          return EventRegisterButton(
            isRegistered: isRegistered,

            onRegister: () async {
              try {
                await RegistrationService().registerForEvent(eventId);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },

            badgeColor: status.badgeColor,
            textColor: status.textColor,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
