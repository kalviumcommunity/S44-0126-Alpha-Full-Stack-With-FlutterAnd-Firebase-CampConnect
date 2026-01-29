import 'package:flutter/material.dart';
import '../data/dummy_events.dart';
import '../utils/date_utils.dart';
import 'event_detail_screen.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final screens = const [HomeTab(), EventListScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final today = todayDate();
    final endDate = today.add(const Duration(days: 2));

    final upcomingEvents =
        dummyEvents.where((e) {
          final date = parseDate(e['date']!);
          return !date.isBefore(today) && !date.isAfter(endDate);
        }).toList()..sort(
          (a, b) => parseDate(a['date']!).compareTo(parseDate(b['date']!)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = upcomingEvents[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                event['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '📅 ${formatDate(event['date']!)}\n📍 ${event['location']}',
              ),
              trailing: const Icon(Icons.chevron_right),
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
      ),
    );
  }
}
