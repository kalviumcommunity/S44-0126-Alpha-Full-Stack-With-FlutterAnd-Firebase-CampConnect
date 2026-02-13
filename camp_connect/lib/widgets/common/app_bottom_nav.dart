import 'package:flutter/material.dart';

// ================= APP BOTTOM NAV =================

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // ================= STATE =================

  final int currentIndex;
  final ValueChanged<int> onTap;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Container(
        width: double.infinity,

        // ================= CONTAINER UI =================
        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),

              blurRadius: 8,

              offset: const Offset(0, -2),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: BottomNavigationBar(
            // ================= CONFIG =================
            currentIndex: currentIndex,

            onTap: onTap,

            type: BottomNavigationBarType.fixed,

            elevation: 0,

            backgroundColor: Colors.transparent,

            selectedItemColor: Colors.deepPurple,

            unselectedItemColor: Colors.black54,

            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),

            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),

            // ================= ITEMS =================
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),

                activeIcon: Icon(Icons.home),

                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),

                activeIcon: Icon(Icons.event),

                label: 'Events',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),

                activeIcon: Icon(Icons.person),

                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
