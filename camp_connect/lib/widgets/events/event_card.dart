import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../utils/event_status_helper.dart';
import '../admin/admin_event_card_action_buttons.dart';

// ================= EVENT CARD =================

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  final VoidCallback? onTap;

  final bool isRegistered;
  final bool isAdmin;

  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.isRegistered = false,
    this.isAdmin = false,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = EventStatusHelper.resolve(event);

    final bool canModify =
        isAdmin && !status.isCancelled && !status.isPast && !status.isCompleted;

    final bool shouldDim = status.isCancelled || status.isPast;

    return Stack(
      children: [
        // ================= CARD =================
        Opacity(
          opacity: shouldDim ? 0.6 : 1,

          child: Card(
            elevation: shouldDim ? 0 : 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ================= TITLE =================
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (isRegistered)
                          Container(
                            margin: const EdgeInsets.only(left: 6),

                            width: 8,
                            height: 8,

                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),

                        const Icon(Icons.chevron_right),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ================= DATE & TIME =================
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),

                        Text(
                          formatDate(event['date']),
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(width: 32),

                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),

                        Text(
                          formatTimeRange(event['startTime'], event['endTime']),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // ================= LOCATION =================
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),

                        Expanded(child: Text(event['location'])),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ================= STATUS =================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: status.badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        status.text,

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ================= ADMIN ACTIONS =================
        if (canModify)
          Positioned(
            bottom: 18,
            right: 18,

            child: Row(
              children: [
                AdminCircleButton(
                  icon: Icons.edit,

                  bgColor: Colors.blue.shade100,
                  borderColor: Colors.blue.shade700,
                  iconColor: Colors.blue.shade700,
                  tooltip: 'Edit Event',

                  onTap: onEdit,
                ),

                const SizedBox(width: 8),

                AdminCircleButton(
                  icon: Icons.close,

                  bgColor: Colors.red.shade100,
                  borderColor: Colors.red.shade700,
                  iconColor: Colors.red.shade700,
                  tooltip: 'Cancel Event',

                  onTap: onCancel,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
