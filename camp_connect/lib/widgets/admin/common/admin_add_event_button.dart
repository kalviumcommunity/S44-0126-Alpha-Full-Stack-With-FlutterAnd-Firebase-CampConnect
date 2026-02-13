import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

// ================= ADMIN ADD EVENT BUTTON =================

class AdminAddEventButton extends StatelessWidget {
  const AdminAddEventButton({super.key, required this.onTap});

  // ================= CALLBACK =================

  final VoidCallback onTap;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<bool>(
      stream: authService.isAdminStream(),

      builder: (context, snapshot) {
        final bool isAdmin = snapshot.data ?? false;

        if (!isAdmin) {
          return const SizedBox.shrink();
        }

        return Material(
          elevation: 6,

          color: Colors.deepPurple,

          shape: const CircleBorder(),

          child: InkWell(
            customBorder: const CircleBorder(),

            onTap: onTap,

            child: const Padding(
              padding: EdgeInsets.all(16),

              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        );
      },
    );
  }
}
