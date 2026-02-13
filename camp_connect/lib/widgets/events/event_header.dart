import 'package:flutter/material.dart';

class EventHeader extends StatelessWidget {
  const EventHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.metaText,
  });

  // ================= CONFIG =================

  final String title;
  final IconData icon;
  final String metaText;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        // ================= TITLE =================
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 8),

        // ================= META =================
        Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, size: 14, color: Colors.grey),

            const SizedBox(width: 4),

            Flexible(
              child: Text(
                metaText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
