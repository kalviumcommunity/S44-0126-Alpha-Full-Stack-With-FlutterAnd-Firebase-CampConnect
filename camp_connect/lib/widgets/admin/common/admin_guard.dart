import 'package:camp_connect/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<bool>(
      stream: authService.isAdminStream(),
      builder: (context, snapshot) {
        final bool isAdmin = snapshot.data ?? false;

        if (!isAdmin) {
          return const Scaffold(
            body: Center(child: Text('Unauthorized access')),
          );
        }

        return child;
      },
    );
  }
}
