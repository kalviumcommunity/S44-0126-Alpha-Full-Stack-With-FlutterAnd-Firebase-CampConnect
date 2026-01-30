import 'package:flutter/material.dart';
import '../data/dummy_events.dart';
import '../utils/date_utils.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = todayDate();

    final upcomingEvents =
        dummyEvents
            .where((e) => !parseDate(e['date']!).isBefore(today))
            .toList()
          ..sort(
            (a, b) => parseDate(a['date']!).compareTo(parseDate(b['date']!)),
          );

    final pastEvents =
        dummyEvents.where((e) => parseDate(e['date']!).isBefore(today)).toList()
          ..sort(
            (a, b) => parseDate(a['date']!).compareTo(parseDate(b['date']!)),
          );

    final orderedEvents = [...upcomingEvents, ...pastEvents];

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderedEvents.length,
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
      ),
    );
  }
}
