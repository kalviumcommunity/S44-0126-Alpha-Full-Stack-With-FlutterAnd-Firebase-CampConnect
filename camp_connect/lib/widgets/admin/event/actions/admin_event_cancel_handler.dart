import 'package:flutter/material.dart';

import '../../services/event_service.dart';
import 'admin_event_cancel_dialog.dart';

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
