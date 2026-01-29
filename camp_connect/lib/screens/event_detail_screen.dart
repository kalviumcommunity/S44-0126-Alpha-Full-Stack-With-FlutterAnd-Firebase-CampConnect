import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, String> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isPast = parseDate(event['date']!).isBefore(todayDate());

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title']!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('📅 ${formatDate(event['date']!)}'),
            const SizedBox(height: 8),
            Text('📍 ${event['location']}'),
            const SizedBox(height: 16),
            const Divider(),
            Text(event['description'] ?? 'No description available'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPast
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration feature coming soon'),
                          ),
                        );
                      },
                child: Text(isPast ? 'Event Ended' : 'Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
