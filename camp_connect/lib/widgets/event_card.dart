import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? onTap;
  final bool isRegistered;

  // ADMIN CONTROLS
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
    final eventDate = normalizeDate(event['date']);
    final today = todayDate();

    final isPast = eventDate.isBefore(today);
    final isToday = eventDate.isAtSameMomentAs(today);

    final status = event['status'] ?? 'active';
    final isCancelled = status == 'cancelled';

    // 🚫 ONLY ALLOW UPDATE / CANCEL FOR FUTURE EVENTS
    final canModify = isAdmin && !isCancelled && !isPast;

    late String statusText;
    late Color badgeColor;
    late Color badgeTextColor;

    if (isCancelled) {
      statusText = 'Cancelled';
      badgeColor = Colors.red.shade100;
      badgeTextColor = Colors.red.shade800;
    } else if (isPast) {
      statusText = 'Event Ended';
      badgeColor = Colors.grey.shade300;
      badgeTextColor = Colors.grey.shade700;
    } else if (isToday) {
      statusText = 'Event Today';
      badgeColor = Colors.orange.shade100;
      badgeTextColor = Colors.orange.shade800;
    } else {
      statusText = 'Upcoming Event';
      badgeColor = Colors.green.shade100;
      badgeTextColor = Colors.green.shade800;
    }

    return Stack(
      children: [
        // ================= CARD =================
        Opacity(
          opacity: isCancelled || isPast ? 0.6 : 1,
          child: Card(
            elevation: isCancelled || isPast ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap, // ✅ navigation stays enabled
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
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

                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(formatDate(event['date'])),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(event['location'])),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ================= ADMIN BUTTONS =================
        if (canModify)
          Positioned(
            bottom: 18,
            right: 18,
            child: Row(
              children: [
                _AdminCircleButton(
                  icon: Icons.edit,
                  bgColor: Colors.blue.shade100,
                  borderColor: Colors.blue.shade700,
                  iconColor: Colors.blue.shade700,
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _AdminCircleButton(
                  icon: Icons.close,
                  bgColor: Colors.red.shade100,
                  borderColor: Colors.red.shade700,
                  iconColor: Colors.red.shade700,
                  onTap: onCancel,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ================= ADMIN BUTTON =================
class _AdminCircleButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _AdminCircleButton({
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
