import 'package:camp_connect/services/auth_service.dart';
import 'package:flutter/material.dart';

// ================= ADMIN BADGE =================

class AdminBadge extends StatelessWidget {
  const AdminBadge({
    super.key,
    this.padding = const EdgeInsets.only(right: 12),
  });

  // ================= CONFIG =================

  final EdgeInsets padding;

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

        return Padding(
          padding: padding,

          child: Chip(
            backgroundColor: Colors.deepPurple,

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            label: const Text(
              'ADMIN',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
