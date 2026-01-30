import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../utils/date_utils.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 930;

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: EventService().streamEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          final today = todayDate();

          // 🔹 Split events
          final upcomingEvents = snapshot.data!.where((e) {
            final date = normalizeDate(e['date']);
            return !date.isBefore(today);
          }).toList()..sort((a, b) => a['date'].compareTo(b['date']));

          final pastEvents =
              snapshot.data!.where((e) {
                final date = normalizeDate(e['date']);
                return date.isBefore(today);
              }).toList()..sort(
                (a, b) => b['date'].compareTo(a['date']),
              ); // recent first

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
      ),
    );
  }
}
