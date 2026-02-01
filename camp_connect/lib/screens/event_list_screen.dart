import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import 'admin/create_event_screen.dart';
import '../utils/date_utils.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 930;

    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 🔹 ADMIN-ONLY STICKY BUTTON
      floatingActionButton: StreamBuilder<Map<String, dynamic>?>(
        stream: authService.streamUserProfile(),
        builder: (context, snapshot) {
          final isAdmin = snapshot.data?['role'] == 'admin';
          if (!isAdmin) return const SizedBox.shrink();

          return Material(
            elevation: 6,
            color: Colors.deepPurple,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCreateEventScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No events found'));
              }

              final today = todayDate();

              final upcomingEvents = <Map<String, dynamic>>[];
              final pastEvents = <Map<String, dynamic>>[];

              for (final event in snapshot.data!) {
                final date = normalizeDate(event['date']);
                if (date.isBefore(today)) {
                  pastEvents.add(event);
                } else {
                  upcomingEvents.add(event);
                }
              }

              upcomingEvents.sort((a, b) => a['date'].compareTo(b['date']));
              pastEvents.sort((a, b) => b['date'].compareTo(a['date']));

              final orderedEvents = [...upcomingEvents, ...pastEvents];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isWide
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orderedEvents.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 2.8,
                              ),
                          itemBuilder: (context, index) {
                            final event = orderedEvents[index];
                            return EventCard(
                              event: event,
                              isRegistered: registeredIds.contains(event['id']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailScreen(event: event),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orderedEvents.length,
                          itemBuilder: (context, index) {
                            final event = orderedEvents[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EventCard(
                                event: event,
                                isRegistered: registeredIds.contains(
                                  event['id'],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailScreen(event: event),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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
