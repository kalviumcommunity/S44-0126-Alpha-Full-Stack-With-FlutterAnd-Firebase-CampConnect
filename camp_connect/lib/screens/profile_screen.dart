import 'package:camp_connect/screens/event_detail_screen.dart';
import 'package:camp_connect/screens/login_screen.dart';
import 'package:camp_connect/services/auth_service.dart';
import 'package:camp_connect/services/event_service.dart';
import 'package:camp_connect/services/registration_service.dart';
import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:camp_connect/widgets/admin/common/admin_badge.dart';
import 'package:camp_connect/widgets/events/event_empty_state.dart';
import 'package:camp_connect/widgets/events/event_card_item.dart';
import 'package:camp_connect/widgets/events/event_responsive_list.dart';
import 'package:flutter/material.dart';

// ================= PROFILE =================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ================= LOGOUT =================

  Future<void> _logout(BuildContext context, AuthService authService) async {
    try {
      await authService.logout();
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logout failed')));
      return;
    }

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return CustomScrollView(
      slivers: [
        // ================= APP BAR =================
        const SliverAppBar(
          pinned: true,
          centerTitle: true,
          title: Text('Profile'),
          actions: [AdminBadge()],
        ),

        // ================= PROFILE INFO =================
        SliverPadding(
          padding: const EdgeInsets.all(16),

          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 8),

                    // ================= USER INFO =================
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(
                            Icons.person,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: StreamBuilder<Map<String, dynamic>?>(
                            stream: authService.streamUserProfile(),

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final data = snapshot.data;

                              final email =
                                  authService.currentUser?.email ?? '';

                              final role = (data?['role'] ?? 'student')
                                  .toString();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    role[0].toUpperCase() + role.substring(1),

                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        IconButton(
                          tooltip: 'Logout',
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () => _logout(context, authService),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),

                    // ================= TITLE =================
                    const Text(
                      'My Registrations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ================= REGISTRATIONS / EMPTY =================
        SliverToBoxAdapter(
          child: StreamBuilder<List<String>>(
            stream: RegistrationService().streamUserRegistrations(),

            builder: (context, regSnapshot) {
              final registeredIds = regSnapshot.data ?? [];

              // ================= EMPTY =================

              if (registeredIds.isEmpty) {
                return const EmptyEventState(text: 'No registrations yet');
              }

              // ================= EVENTS =================

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: EventService().streamEvents(),

                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final eventMap = {
                    for (final e in eventSnapshot.data!) e['id']: e,
                  };

                  final registeredEvents = registeredIds
                      .where(eventMap.containsKey)
                      .map((id) => eventMap[id]!)
                      .toList();

                  if (registeredEvents.isEmpty) {
                    return const EmptyEventState(text: 'No registrations yet');
                  }

                  final upcoming = <Map<String, dynamic>>[];
                  final past = <Map<String, dynamic>>[];

                  for (final event in registeredEvents) {
                    isEventEnded(event) ? past.add(event) : upcoming.add(event);
                  }

                  upcoming.sort(
                    (a, b) => getEventEndDateTime(
                      a,
                    ).compareTo(getEventEndDateTime(b)),
                  );

                  past.sort(
                    (a, b) => getEventEndDateTime(
                      b,
                    ).compareTo(getEventEndDateTime(a)),
                  );

                  final ordered = [...upcoming, ...past];

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: EventResponsiveList(
                          events: ordered,

                          itemBuilder: (context, event) {
                            return EventCardItem(
                              event: event,
                              isRegistered: true,

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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
