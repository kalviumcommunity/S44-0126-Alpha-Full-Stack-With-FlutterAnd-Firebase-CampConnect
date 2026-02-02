import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminBadge extends StatelessWidget {
  const AdminBadge({
    super.key,
    this.padding = const EdgeInsets.only(right: 12),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: authService.streamUserProfile(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data?['role'] == 'admin';
        if (!isAdmin) return const SizedBox.shrink();

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
