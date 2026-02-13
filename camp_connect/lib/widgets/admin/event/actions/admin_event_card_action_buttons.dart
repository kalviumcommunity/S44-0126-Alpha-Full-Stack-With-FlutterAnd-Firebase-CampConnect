import 'package:flutter/material.dart';

// ================= ADMIN CIRCLE BUTTON =================

class AdminCircleButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final String? tooltip;
  final VoidCallback? onTap;

  const AdminCircleButton({
    super.key,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
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
      ),
    );
  }
}
