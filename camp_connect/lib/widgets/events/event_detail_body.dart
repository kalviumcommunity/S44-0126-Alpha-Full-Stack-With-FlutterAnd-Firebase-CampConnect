import 'package:camp_connect/utils/event_meta_helper.dart';
import 'package:camp_connect/utils/event_status_helper.dart';
import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import 'event_header.dart';
import 'event_status_badge.dart';

// ================= EVENT DETAIL BODY =================

class EventDetailBody extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailBody({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final status = EventStatusHelper.resolve(event);

    final meta = EventMetaHelper.resolve(event);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ================= HEADER =================
          EventHeader(
            title: event['title'],
            icon: meta.icon,
            metaText: meta.text,
          ),

          const SizedBox(height: 16),

          // ================= DATE / TIME =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),

                  Text(formatDate(event['date'])),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 6),

                  Text(formatTimeRange(event['startTime'], event['endTime'])),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ================= LOCATION =================
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),

              Expanded(child: Text(event['location'])),
            ],
          ),

          const SizedBox(height: 16),

          // ================= STATUS =================
          EventStatusBadge(
            text: status.text,
            badgeColor: status.badgeColor,
            textColor: status.textColor,
          ),

          const SizedBox(height: 20),

          const Divider(),
          const SizedBox(height: 12),

          // ================= DESCRIPTION =================
          Text(
            event['description'] ?? 'No description available',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
