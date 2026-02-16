import 'package:camp_connect/screens/event_detail_screen.dart';
import 'package:camp_connect/screens/event_list_screen.dart';
import 'package:camp_connect/screens/profile_screen.dart';
import 'package:camp_connect/services/event_service.dart';
import 'package:camp_connect/services/registration_service.dart';
import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:camp_connect/widgets/admin/common/admin_badge.dart';
import 'package:camp_connect/widgets/common/app_bottom_nav.dart';
import 'package:camp_connect/widgets/events/event_card_item.dart';
import 'package:camp_connect/widgets/events/event_empty_state.dart';
import 'package:camp_connect/widgets/events/event_responsive_list.dart';
import 'package:flutter/material.dart';

// ================= HOME SCREEN =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeTab(),
    EventListScreen(),
    ProfileScreen(),
  ];

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

// ================= HOME TAB =================

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = todayDate();

    return StreamBuilder<List<String>>(
      stream: RegistrationService().streamUserRegistrations(),

      builder: (context, regSnapshot) {
        final registeredIds = regSnapshot.data ?? [];

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: EventService().streamEvents(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!;

            // ================= FILTER TODAY =================

            final todayEvents = events.where((event) {
              final start = getEventStartDateTime(event);
              final end = getEventEndDateTime(event);

              final isToday = normalizeDate(start) == today;

              final notEnded = now.isBefore(end);

              return isToday && notEnded;
            }).toList();

            // ================= SORT =================

            todayEvents.sort(
              (a, b) =>
                  getEventEndDateTime(a).compareTo(getEventEndDateTime(b)),
            );

            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  centerTitle: true,
                  title: Text('Today’s Events'),
                  actions: [AdminBadge()],
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),

                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),

                        child: todayEvents.isEmpty
                            ? const EmptyEventState(
                                text: 'No more events today',
                              )
                            : EventResponsiveList(
                                events: todayEvents,

                                itemBuilder: (context, event) {
                                  return EventCardItem(
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
                                  );
                                },
                              ),
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
}
