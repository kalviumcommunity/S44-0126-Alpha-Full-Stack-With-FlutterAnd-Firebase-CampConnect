import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/registration_service.dart';

import '../utils/date_utils.dart';

import '../widgets/event_card.dart';
import '../widgets/admin_badge.dart';

import 'event_detail_screen.dart';
import 'login_screen.dart';

// ================= PROFILE SCREEN =================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ================= EMPTY STATE =================

  Widget _emptyRegistrations() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),

      child: Center(
        child: Text(
          'No registrations yet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // ================= LOGOUT =================

  Future<void> _logout(BuildContext context, AuthService authService) async {
    try {
      await authService.logout();
    } catch (e) {
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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // ================= SERVICES =================

    final authService = AuthService();

    // ================= LAYOUT =================

    final size = MediaQuery.of(context).size;

    final bool isWide = size.width >= 930;

    return CustomScrollView(
      slivers: [
        // ================= APP BAR =================
        const SliverAppBar(
          pinned: true,

          centerTitle: true,

          title: Text('Profile'),

          actions: [AdminBadge()],
        ),

        // ================= CONTENT =================
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

                    // ================= USER INFO HEADER =================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= PROFILE IMAGE =================
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

                        // ================= USER DETAILS =================
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

                        // ================= LOGOUT BUTTON =================
                        IconButton(
                          tooltip: 'Logout',

                          icon: const Icon(Icons.logout, color: Colors.red),

                          onPressed: () {
                            _logout(context, authService);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const Divider(),

                    const SizedBox(height: 24),

                    // ================= REGISTRATIONS =================
                    const Text(
                      'My Registrations',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    StreamBuilder<List<String>>(
                      stream: RegistrationService().streamUserRegistrations(),

                      builder: (context, regSnapshot) {
                        final registeredIds = regSnapshot.data ?? [];

                        if (registeredIds.isEmpty) {
                          return _emptyRegistrations();
                        }

                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: EventService().streamEvents(),

                          builder: (context, eventSnapshot) {
                            if (!eventSnapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(32),

                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // ================= DATA =================

                            final today = todayDate();

                            final eventMap = {
                              for (final e in eventSnapshot.data!) e['id']: e,
                            };

                            final registeredEvents = registeredIds
                                .where((id) => eventMap.containsKey(id))
                                .map((id) => eventMap[id]!)
                                .toList();

                            if (registeredEvents.isEmpty) {
                              return _emptyRegistrations();
                            }

                            final upcoming = <Map<String, dynamic>>[];

                            final past = <Map<String, dynamic>>[];

                            for (final event in registeredEvents) {
                              normalizeDate(event['date']).isBefore(today)
                                  ? past.add(event)
                                  : upcoming.add(event);
                            }

                            // ================= SORT =================

                            upcoming.sort(
                              (a, b) => a['date'].compareTo(b['date']),
                            );

                            past.sort((a, b) => b['date'].compareTo(a['date']));

                            final ordered = [...upcoming, ...past];

                            // ================= UI =================

                            return isWide
                                ? _buildGrid(context, ordered)
                                : _buildList(context, ordered);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= GRID =================

  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> events) {
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

        return _buildEventCard(context, event);
      },
    );
  }

  // ================= LIST =================

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> events) {
    return ListView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: events.length,

      itemBuilder: (context, index) {
        final event = events[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),

          child: _buildEventCard(context, event),
        );
      },
    );
  }

  // ================= EVENT CARD =================

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    return EventCard(
      event: event,

      isRegistered: true,

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );
      },
    );
  }
}
