import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminAddEventButton extends StatelessWidget {
  const AdminAddEventButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: authService.streamUserProfile(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data?['role'] == 'admin';
        if (!isAdmin) return const SizedBox.shrink();

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
