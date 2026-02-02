import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import '../widgets/admin_badge.dart';
import '../widgets/admin_add_event_button.dart';
import '../widgets/cancel_event_dialog.dart';
import '../utils/date_utils.dart';
import 'admin/create_event_screen.dart';
import 'admin/edit_event_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

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
            MaterialPageRoute(builder: (_) => const AdminCreateEventScreen()),
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
              final today = todayDate();

              final upcoming = <Map<String, dynamic>>[];
              final past = <Map<String, dynamic>>[];

              for (final e in events) {
                normalizeDate(e['date']).isBefore(today)
                    ? past.add(e)
                    : upcoming.add(e);
              }

              upcoming.sort((a, b) => a['date'].compareTo(b['date']));
              past.sort((a, b) => b['date'].compareTo(a['date']));

              final ordered = [...upcoming, ...past];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ordered.length,
                itemBuilder: (context, i) {
                  final event = ordered[i];
                  final isOwnerAdmin =
                      currentUserId != null &&
                      event['createdBy'] == currentUserId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EventCard(
                      event: event,
                      isRegistered: registeredIds.contains(event['id']),
                      isAdmin: isOwnerAdmin,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminEditEventScreen(event: event),
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
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
