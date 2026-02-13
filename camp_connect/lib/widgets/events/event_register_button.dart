import 'package:flutter/material.dart';

// ================= EVENT REGISTER BUTTON =================

class EventRegisterButton extends StatelessWidget {
  final bool isRegistered;
  final VoidCallback? onRegister;

  final Color badgeColor;
  final Color textColor;

  const EventRegisterButton({
    super.key,
    required this.isRegistered,
    required this.onRegister,
    required this.badgeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),

      child: SizedBox(
        width: size.width > 720 ? 400 : double.infinity,
        height: 52,

        child: OutlinedButton(
          onPressed: isRegistered ? null : onRegister,

          style: OutlinedButton.styleFrom(
            backgroundColor: isRegistered ? Colors.grey.shade200 : badgeColor,

            foregroundColor: isRegistered ? Colors.grey : textColor,

            side: BorderSide(color: textColor.withAlpha((0.4 * 255).toInt())),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          child: Text(
            isRegistered ? 'Registered' : 'Register',

            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
