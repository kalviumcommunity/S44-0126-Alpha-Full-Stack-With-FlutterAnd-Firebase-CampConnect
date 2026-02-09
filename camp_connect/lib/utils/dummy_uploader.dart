import '../data/dummy_events.dart';
import '../services/event_service.dart';

class DummyUploader {
  static Future<void> uploadAll() async {
    final service = EventService();

    for (final event in dummyEvents) {
      final parts = event['date'].split('-');

      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      await service.createEvent(
        title: event['title'],
        description: event['description'],
        location: event['location'],
        date: date,
        startTime: event['startTime'],
        endTime: event['endTime'],
      );
    }
  }
}
