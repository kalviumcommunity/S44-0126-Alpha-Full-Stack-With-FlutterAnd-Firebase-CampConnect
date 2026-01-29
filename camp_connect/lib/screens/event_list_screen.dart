import 'package:flutter/material.dart';
import 'event_detail_screen.dart';

final List<Map<String, String>> dummyEvents = [
  {
    'title': 'Tech Talk: Flutter Basics',
    'date': '12 Oct 2026',
    'location': 'Auditorium A',
    'description': 'An introductory session on Flutter fundamentals.',
  },
  {
    'title': 'AI Club Orientation',
    'date': '15 Oct 2026',
    'location': 'Room 204',
    'description': 'Orientation for new members of the AI Club.',
  },
  {
    'title': 'Hackathon Meetup',
    'date': '20 Oct 2026',
    'location': 'Innovation Lab',
    'description': 'Meet fellow hackers and form teams.',
  },
];

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Events'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyEvents.length,
        itemBuilder: (context, index) {
          final event = dummyEvents[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('📅 ${event['date']}'),
                          const SizedBox(height: 4),
                          Text('📍 ${event['location']}'),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
