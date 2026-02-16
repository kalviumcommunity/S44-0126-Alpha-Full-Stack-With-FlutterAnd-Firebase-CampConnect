import 'package:camp_connect/services/event_service.dart';
import 'package:camp_connect/widgets/admin/event/actions/admin_event_action_button.dart';
import 'package:camp_connect/widgets/admin/event/actions/admin_event_dialog_complete.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSheet extends StatelessWidget {
  const AttendanceSheet({
    super.key,
    required this.eventId,
    required this.isCompleted,
    required this.isEnded,
  });

  final String eventId;
  final bool isCompleted;
  final bool isEnded;

  // Lock when completed OR ended
  bool get isLocked => isCompleted || isEnded;

  // ================= ATTACH EMAILS =================

  Future<List<Map<String, dynamic>>> _attachEmails(
    List<Map<String, dynamic>> regs,
  ) async {
    if (regs.isEmpty) return [];

    final userIds = regs.map((r) => r['userId'] as String).toSet().toList();

    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    final emailMap = {
      for (var doc in usersSnap.docs) doc.id: doc.data()['email'] ?? 'Unknown',
    };

    return regs.map((r) {
      final email = emailMap[r['userId']] ?? 'Unknown';
      return {...r, 'email': email};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // ================= HEADER =================
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Attendance Sheet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ================= LIST =================
          SizedBox(
            height: 220,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: EventService().streamRegistrationsForEvent(eventId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load attendance'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final regs = snapshot.data!;

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _attachEmails(regs),
                  builder: (context, emailSnap) {
                    if (!emailSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = emailSnap.data!
                      ..sort(
                        (a, b) => (a['email'] as String).compareTo(b['email']),
                      );

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final reg = list[i];
                        final bool attended = reg['attended'] == true;

                        return ListTile(
                          dense: true,
                          title: Text(reg['email']),
                          trailing: isLocked
                              ? Icon(
                                  attended ? Icons.check_circle : Icons.cancel,
                                  color: attended ? Colors.green : Colors.red,
                                )
                              : Switch(
                                  value: attended,
                                  activeThumbColor: Colors.deepPurple,
                                  onChanged: (val) async {
                                    await EventService().markAttendance(
                                      registrationId: reg['id'],
                                      attended: val,
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
          ),

          // ================= STATS (ONLY WHEN CLOSED) =================
          if (isLocked)
            FutureBuilder<Map<String, int>>(
              future: EventService().getAttendanceStats(eventId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(),
                  );
                }

                final stats = snapshot.data!;
                final registered = stats['registered'] ?? 0;
                final attended = stats['attended'] ?? 0;

                final percent = registered == 0
                    ? 0
                    : ((attended / registered) * 100).round();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Attendance: $attended / $registered ($percent%)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                );
              },
            ),

          // ================= COMPLETE / STATUS =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: isLocked
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'Event Closed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : EventActionButton(
                      text: 'Complete Event',
                      bgColor: Colors.deepPurple.shade100,
                      textColor: Colors.deepPurple.shade800,
                      onPressed: () async {
                        try {
                          final confirm = await CompleteEventDialog.show(
                            context,
                          );

                          if (confirm != true) return;

                          await EventService().completeEvent(eventId);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event Completed')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Something went wrong. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
