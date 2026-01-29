import 'package:flutter/material.dart';
import '../data/dummy_events.dart';
import '../utils/date_utils.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = todayDate();

    // 🟢 Upcoming + today events
    final upcomingEvents =
        dummyEvents
            .where((e) => !parseDate(e['date']!).isBefore(today))
            .toList()
          ..sort(
            (a, b) => parseDate(a['date']!).compareTo(parseDate(b['date']!)),
          );

    // 🔴 Past events
    final pastEvents =
        dummyEvents.where((e) => parseDate(e['date']!).isBefore(today)).toList()
          ..sort(
            (a, b) => parseDate(a['date']!).compareTo(parseDate(b['date']!)),
          );

    // 🔥 Final list: upcoming first, past last
    final orderedEvents = [...upcomingEvents, ...pastEvents];

    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderedEvents.length,
        itemBuilder: (context, index) {
          final event = orderedEvents[index];
          final isPast = parseDate(event['date']!).isBefore(today);

          return Card(
            color: isPast ? Colors.grey.shade200 : null,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                event['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPast ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                '📅 ${formatDate(event['date']!)}\n📍 ${event['location']}',
                style: TextStyle(color: isPast ? Colors.grey : Colors.black),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isPast ? Colors.grey : Colors.black,
              ),
              onTap: isPast
                  ? null
                  : () {
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
      ),
    );
  }
}
