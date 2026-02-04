import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/event_service.dart';

import 'event_action_button.dart';

// ================= ATTENDANCE SHEET =================

class AttendanceSheet extends StatelessWidget {
  const AttendanceSheet({
    super.key,
    required this.eventId,
    required this.isCompleted,
  });

  // ================= CONFIG =================

  final String eventId;
  final bool isCompleted;

  // ================= HELPERS =================

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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // ================= CONTAINER UI =================
      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),

      child: Column(
        children: [
          // ================= HEADER =================
          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: const [
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

                    final list = emailSnap.data!;

                    // ================= SORT =================

                    list.sort((a, b) => a['email'].compareTo(b['email']));

                    return ListView.builder(
                      itemCount: list.length,

                      itemBuilder: (context, i) {
                        final reg = list[i];

                        final bool attended = reg['attended'] == true;

                        return ListTile(
                          dense: true,

                          title: Text(reg['email']),

                          // ================= ACTION =================
                          trailing: isCompleted
                              // AFTER COMPLETE → ICON
                              ? Icon(
                                  attended ? Icons.check_circle : Icons.cancel,

                                  color: attended ? Colors.green : Colors.red,
                                )
                              // BEFORE COMPLETE → SWITCH
                              : Switch(
                                  value: attended,

                                  activeColor: Colors.deepPurple,

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

          // ================= COMPLETE / STATUS =================
          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,
              height: 48,

              child: isCompleted
                  // ================= COMPLETED =================
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.check_circle, color: Colors.deepPurple),

                            SizedBox(width: 8),

                            Text(
                              'Event Completed',

                              style: TextStyle(
                                fontWeight: FontWeight.w600,

                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // ================= COMPLETE BUTTON =================
                  : EventActionButton(
                      text: 'Complete Event',

                      bgColor: Colors.deepPurple.shade100,

                      textColor: Colors.deepPurple.shade800,

                      onPressed: () async {
                        await EventService().completeEvent(eventId);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event Completed')),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
