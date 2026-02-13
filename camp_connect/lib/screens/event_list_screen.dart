import 'package:camp_connect/widgets/admin/admin_dummy_upload_button.dart';
import 'package:camp_connect/widgets/events/event_card_item.dart';
import 'package:camp_connect/widgets/events/event_empty_state.dart';
import 'package:camp_connect/widgets/events/event_responsive_list.dart';
import 'package:camp_connect/widgets/admin/admin_add_event_button.dart';
import 'package:flutter/material.dart';

import '../services/registration_service.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';

import '../widgets/admin/admin_badge.dart';
import '../widgets/admin/admin_event_cancel_dialog.dart';

import '../utils/date_time_utils.dart';

import 'admin/event_create_edit_screen.dart';
import 'event_detail_screen.dart';

// ================= EVENT LIST =================

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  // ================= CANCEL =================

  Future<void> _confirmAndCancelEvent(
    BuildContext context,
    String eventId,
  ) async {
    final confirmed = await CancelEventDialog.show(context);

    if (confirmed != true) return;

    try {
      await EventService().cancelEvent(eventId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade50,
          content: Text(
            'Event cancelled',
            style: TextStyle(color: Colors.red.shade800),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        centerTitle: true,
        actions: const [AdminBadge()],
      ),

      floatingActionButton: AdminAddEventButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminEventScreen(mode: EventMode.create),
            ),
          );
        },
      ),

      body: StreamBuilder<List<String>>(
        stream: RegistrationService().streamUserRegistrations(),

        builder: (context, regSnapshot) {
          final registeredIds = regSnapshot.data ?? [];

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: EventService().streamEvents(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data!;
              if (events.isEmpty) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: EmptyEventState(
                        text: 'No events available',
                        action: const AdminDummyUploadButton(),
                      ),
                    ),
                  ),
                );
              }

              final now = DateTime.now();

              final upcoming = <Map<String, dynamic>>[];
              final past = <Map<String, dynamic>>[];

              // ================= SPLIT =================

              for (final event in events) {
                final end = getEventEndDateTime(event);

                end.isBefore(now) ? past.add(event) : upcoming.add(event);
              }

              // ================= SORT =================

              upcoming.sort(
                (a, b) =>
                    getEventEndDateTime(a).compareTo(getEventEndDateTime(b)),
              );

              past.sort(
                (a, b) =>
                    getEventEndDateTime(b).compareTo(getEventEndDateTime(a)),
              );

              final ordered = [...upcoming, ...past];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: EventResponsiveList(
                      events: ordered,

                      shrinkWrap: false,
                      physics: const AlwaysScrollableScrollPhysics(),

                      itemBuilder: (context, event) {
                        final isOwner =
                            currentUserId != null &&
                            event['createdBy'] == currentUserId;

                        return EventCardItem(
                          event: event,

                          isRegistered: registeredIds.contains(event['id']),

                          isAdmin: isOwner,

                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminEventScreen(
                                  mode: EventMode.edit,
                                  event: event,
                                ),
                              ),
                            );
                          },

                          onCancel: () {
                            _confirmAndCancelEvent(context, event['id']);
                          },

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: event),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
