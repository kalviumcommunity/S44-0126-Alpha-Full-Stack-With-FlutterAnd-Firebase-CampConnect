import 'package:flutter/material.dart';

// ================= CANCEL EVENT DIALOG =================

class CancelEventDialog extends StatelessWidget {
  const CancelEventDialog({super.key});

  // ================= SHOW =================

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (_) => const CancelEventDialog(),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // ================= LAYOUT =================

    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),

        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================= TITLE =================
              const Text(
                'Cancel Event?',

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // ================= DESCRIPTION =================
              Text(
                'Are you sure you want to cancel this event?\n\n'
                'This action cannot be undone and users will see the event as cancelled.',

                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 28),

              // ================= ACTIONS =================
              isWide
                  ? _buildHorizontalActions(context)
                  : _buildVerticalActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ACTION BUILDERS =================

  Widget _buildHorizontalActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DialogButton(
            label: 'No, Keep Event',

            bgColor: Colors.grey.shade200,
            textColor: Colors.grey.shade800,

            onTap: () => Navigator.pop(context, false),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _DialogButton(
            label: 'Yes, Cancel',

            bgColor: Colors.red.shade100,
            textColor: Colors.red.shade800,

            borderColor: Colors.red.shade300,

            onTap: () => Navigator.pop(context, true),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalActions(BuildContext context) {
    return Column(
      children: [
        _DialogButton(
          label: 'Yes, Cancel Event',

          bgColor: Colors.red.shade100,
          textColor: Colors.red.shade800,

          borderColor: Colors.red.shade300,

          onTap: () => Navigator.pop(context, true),
        ),

        const SizedBox(height: 12),

        _DialogButton(
          label: 'No, Go Back',

          bgColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,

          onTap: () => Navigator.pop(context, false),
        ),
      ],
    );
  }
}

// ================= DIALOG BUTTON =================

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  // ================= CONFIG =================

  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,

      child: OutlinedButton(
        onPressed: onTap,

        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,

          foregroundColor: textColor,

          side: BorderSide(color: borderColor ?? Colors.transparent),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),

        child: Text(
          label,

          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
