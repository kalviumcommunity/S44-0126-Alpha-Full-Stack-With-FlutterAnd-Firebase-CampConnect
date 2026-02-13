import 'package:flutter/material.dart';

import 'admin_event_submit_button.dart';

class AdminEventLayout extends StatelessWidget {
  final String title;
  final Widget form;
  final String buttonLabel;
  final VoidCallback onSubmit;

  const AdminEventLayout({
    super.key,
    required this.title,
    required this.form,
    required this.buttonLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // ================= APP BAR =================
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),

            child: Column(
              children: [
                // ================= FORM =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: form,
                  ),
                ),

                // ================= SUBMIT =================
                AdminEventSubmitButton(label: buttonLabel, onPressed: onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
