import 'package:camp_connect/services/event_service.dart';
import 'package:camp_connect/widgets/admin/event/actions/admin_event_dialog_cancel.dart';
import 'package:flutter/material.dart';

class CancelEventHandler {
  static Future<void> confirmAndCancel(
    BuildContext context,
    String eventId,
  ) async {
    final confirmed = await CancelEventDialog.show(context);

    if (confirmed != true) return;

    try {
      await EventService().cancelEvent(eventId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade50,
          content: Text(
            'Event cancelled',
            style: TextStyle(color: Colors.red.shade800),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }
}
