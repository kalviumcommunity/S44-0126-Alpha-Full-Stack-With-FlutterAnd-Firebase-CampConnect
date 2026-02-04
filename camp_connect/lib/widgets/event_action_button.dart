import 'package:flutter/material.dart';

// ================= EVENT ACTION BUTTON =================

class EventActionButton extends StatelessWidget {
  const EventActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.bgColor,
    required this.textColor,
  });

  // ================= CONFIG =================

  final String text;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color textColor;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    return OutlinedButton(
      onPressed: onPressed,

      style: OutlinedButton.styleFrom(
        // ================= COLORS =================
        backgroundColor: isDisabled ? Colors.grey.shade200 : bgColor,

        foregroundColor: isDisabled ? Colors.grey : textColor,

        side: BorderSide(
          color: isDisabled
              ? Colors.grey.shade400
              : textColor.withAlpha((0.4 * 255).toInt()),
        ),

        // ================= SHAPE =================
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      child: Text(
        text,

        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
