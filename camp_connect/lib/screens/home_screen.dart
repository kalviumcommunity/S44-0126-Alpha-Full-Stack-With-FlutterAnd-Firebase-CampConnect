import 'package:flutter/material.dart';
import '../data/dummy_events.dart';
import '../utils/date_utils.dart';
import '../widgets/event_card.dart';
import '../widgets/app_bottom_nav.dart';
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
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
