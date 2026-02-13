import 'package:flutter/material.dart';

class EventStatusBadge extends StatelessWidget {
  const EventStatusBadge({
    super.key,
    required this.text,
    required this.badgeColor,
    required this.textColor,
  });

  // ================= CONFIG =================

  final String text;
  final Color badgeColor;
  final Color textColor;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
