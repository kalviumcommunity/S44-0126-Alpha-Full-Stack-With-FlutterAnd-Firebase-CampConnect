import 'package:camp_connect/widgets/events/event_card.dart';
import 'package:flutter/material.dart';

// ================= EVENT CARD ITEM =================

class EventCardItem extends StatelessWidget {
  final Map<String, dynamic> event;

  final bool isRegistered;
  final bool isAdmin;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const EventCardItem({
    super.key,
    required this.event,
    this.isRegistered = false,
    this.isAdmin = false,
    this.onTap,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,

      isRegistered: isRegistered,
      isAdmin: isAdmin,

      onTap: onTap,
      onEdit: onEdit,
      onCancel: onCancel,
    );
  }
}
