import 'package:flutter/material.dart';

import '../services/event_service.dart';
import '../services/registration_service.dart';

import '../utils/date_time_utils.dart';

import '../widgets/event_card.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/admin_badge.dart';

import 'event_detail_screen.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

// ================= HOME SCREEN =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ================= NAVIGATION =================

  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeTab(),
    EventListScreen(),
    ProfileScreen(),
  ];

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= BODY =================
      body: screens[currentIndex],

      // ================= BOTTOM NAV =================
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}

// ================= HOME TAB =================

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // ================= DATE =================

    final DateTime today = todayDate();

    // ================= LAYOUT =================

    final size = MediaQuery.of(context).size;

    final bool isWide = size.width >= 930;

    return StreamBuilder<List<String>>(
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
              return const Center(child: Text('No upcoming events'));
            }

            // ================= DATA =================

            final events = snapshot.data!;

            final todayEvents = events.where((e) {
              final eventDate = normalizeDate(e['date']);
              return eventDate.isAtSameMomentAs(today);
            }).toList();

            // ================= SORT =================

            todayEvents.sort((a, b) => a['date'].compareTo(b['date']));

            // ================= UI =================

            return CustomScrollView(
              slivers: [
                // ================= APP BAR =================
                const SliverAppBar(
                  pinned: true,

                  centerTitle: true,

                  title: Text('Upcoming Events'),

                  actions: [AdminBadge()],
                ),

                // ================= CONTENT =================
                SliverPadding(
                  padding: const EdgeInsets.all(16),

                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),

                        child: isWide
                            ? _buildGrid(context, todayEvents, registeredIds)
                            : _buildList(context, todayEvents, registeredIds),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= GRID VIEW =================

  Widget _buildGrid(
    BuildContext context,
    List<Map<String, dynamic>> events,
    List<String> registeredIds,
  ) {
    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: events.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        mainAxisSpacing: 16,
        crossAxisSpacing: 16,

        childAspectRatio: 2.8,
      ),

      itemBuilder: (context, index) {
        final event = events[index];

        return _buildEventCard(context, event, registeredIds);
      },
    );
  }

  // ================= LIST VIEW =================

  Widget _buildList(
    BuildContext context,
    List<Map<String, dynamic>> events,
    List<String> registeredIds,
  ) {
    return ListView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: events.length,

      itemBuilder: (context, index) {
        final event = events[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),

          child: _buildEventCard(context, event, registeredIds),
        );
      },
    );
  }

  // ================= EVENT CARD =================

  Widget _buildEventCard(
    BuildContext context,
    Map<String, dynamic> event,
    List<String> registeredIds,
  ) {
    return EventCard(
      event: event,

      isRegistered: registeredIds.contains(event['id']),

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );
      },
    );
  }
}
