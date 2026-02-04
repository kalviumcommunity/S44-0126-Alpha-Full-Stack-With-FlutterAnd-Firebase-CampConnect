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

  // ================= CANCEL EVENT =================

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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // ================= USER =================

    final String? currentUserId = AuthService().currentUser?.uid;

    // ================= LAYOUT =================

    final size = MediaQuery.of(context).size;

    final bool isWide = size.width >= 930;

    // ================= DATE =================

    final DateTime today = todayDate();

    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text('All Events'),

        centerTitle: true,

        actions: const [AdminBadge()],
      ),

      // ================= ADD BUTTON =================
      floatingActionButton: AdminAddEventButton(
        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AdminCreateEventScreen()),
          );
        },
      ),

      // ================= BODY =================
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

              // ================= DATA =================

              final events = snapshot.data!;

              final upcoming = <Map<String, dynamic>>[];
              final past = <Map<String, dynamic>>[];

              for (final event in events) {
                final eventDate = normalizeDate(event['date']);

                eventDate.isBefore(today)
                    ? past.add(event)
                    : upcoming.add(event);
              }

              // ================= SORT =================

              upcoming.sort((a, b) => a['date'].compareTo(b['date']));

              past.sort((a, b) => b['date'].compareTo(a['date']));

              final ordered = [...upcoming, ...past];

              // ================= UI =================

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: isWide
                        ? _buildGrid(
                            context,
                            ordered,
                            registeredIds,
                            currentUserId,
                          )
                        : _buildList(
                            context,
                            ordered,
                            registeredIds,
                            currentUserId,
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

  // ================= GRID VIEW =================

  Widget _buildGrid(
    BuildContext context,
    List<Map<String, dynamic>> events,
    List<String> registeredIds,
    String? currentUserId,
  ) {
    return GridView.builder(
      itemCount: events.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        mainAxisSpacing: 16,
        crossAxisSpacing: 16,

        childAspectRatio: 2.8,
      ),

      itemBuilder: (context, index) {
        final event = events[index];

        return _buildEventCard(context, event, registeredIds, currentUserId);
      },
    );
  }

  // ================= LIST VIEW =================

  Widget _buildList(
    BuildContext context,
    List<Map<String, dynamic>> events,
    List<String> registeredIds,
    String? currentUserId,
  ) {
    return ListView.builder(
      itemCount: events.length,

      itemBuilder: (context, index) {
        final event = events[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),

          child: _buildEventCard(context, event, registeredIds, currentUserId),
        );
      },
    );
  }

  // ================= EVENT CARD =================

  Widget _buildEventCard(
    BuildContext context,
    Map<String, dynamic> event,
    List<String> registeredIds,
    String? currentUserId,
  ) {
    final bool isOwnerAdmin =
        currentUserId != null && event['createdBy'] == currentUserId;

    return EventCard(
      event: event,

      isRegistered: registeredIds.contains(event['id']),

      isAdmin: isOwnerAdmin,

      // ================= EDIT =================
      onEdit: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => AdminEditEventScreen(event: event)),
        );
      },

      // ================= CANCEL =================
      onCancel: () {
        _confirmAndCancelEvent(context, event['id']);
      },

      // ================= DETAILS =================
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );
      },
    );
  }
}
