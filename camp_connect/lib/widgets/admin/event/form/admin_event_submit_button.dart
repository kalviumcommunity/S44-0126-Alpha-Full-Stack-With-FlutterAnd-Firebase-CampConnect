import 'package:flutter/material.dart';

class AdminEventSubmitButton extends StatelessWidget {
  const AdminEventSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  // ================= CONFIG =================

  final String label;
  final VoidCallback onPressed;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),

      child: SizedBox(
        width: size.width > 720 ? 400 : double.infinity,
        height: 52,

        child: ElevatedButton(
          onPressed: onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          child: Text(
            label,

            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
