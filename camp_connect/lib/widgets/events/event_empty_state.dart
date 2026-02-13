import 'package:flutter/material.dart';

// ================= EMPTY EVENTS =================

class EmptyEventState extends StatelessWidget {
  final String text;
  final Widget? action;

  const EmptyEventState({super.key, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(Icons.event_busy, size: 56, color: Colors.grey),

              const SizedBox(height: 12),

              Text(
                text,
                textAlign: TextAlign.center,

                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}
