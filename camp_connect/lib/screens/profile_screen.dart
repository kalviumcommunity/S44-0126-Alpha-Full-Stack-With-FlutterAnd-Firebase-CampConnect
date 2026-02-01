import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/registration_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 930;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          centerTitle: true,
          title: Text('Profile'),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                // ✅ SAME AS HOME TAB
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PROFILE HEADER =================
                    const SizedBox(height: 8),

                    Center(
                      child: Column(
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
                          const SizedBox(height: 16),

                          StreamBuilder<Map<String, dynamic>>(
                            stream: AuthService().streamUserProfile(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final data = snapshot.data!;
                              final email =
                                  AuthService().currentUser?.email ?? '';
                              final role = (data['role'] ?? 'Student')
                                  .toString();

                              return Column(
                                children: [
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),

                    // ================= EVENTS SECTION =================
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
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: Text('No registrations yet')),
                          );
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

                            final events = eventSnapshot.data!
                                .where((e) => registeredIds.contains(e['id']))
                                .toList();

                            // ✅ SAME GRID LOGIC AS HOME TAB
                            return isWide
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: events.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          childAspectRatio: 2.8, // ✅ SAME
                                        ),
                                    itemBuilder: (context, index) {
                                      final event = events[index];
                                      return EventCard(
                                        event: event,
                                        isRegistered: true,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EventDetailScreen(
                                                event: event,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      final event = events[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: EventCard(
                                          event: event,
                                          isRegistered: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EventDetailScreen(
                                                      event: event,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ================= LOGOUT =================
                    Center(
                      child: SizedBox(
                        width: 320,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () async {
                            await AuthService().logout();
                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red.shade800,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
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
}
