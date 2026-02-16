import 'package:camp_connect/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

class AdminEventForm extends StatelessWidget {
  const AdminEventForm({
    super.key,
    required this.formKey,
    required this.titleCtrl,
    required this.descCtrl,
    required this.locationCtrl,
    required this.startTimeCtrl,
    required this.endTimeCtrl,
    required this.selectedDate,
    required this.onPickDate,
    required this.onPickTime,
    required this.isSubmitted,
  });

  // ================= CONFIG =================

  final GlobalKey<FormState> formKey;

  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController startTimeCtrl;
  final TextEditingController endTimeCtrl;

  final DateTime? selectedDate;

  final Future<void> Function(FormFieldState<DateTime>) onPickDate;
  final void Function(TextEditingController) onPickTime;

  final bool isSubmitted;

  // ================= INPUT UI =================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.6),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,

      autovalidateMode: isSubmitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,

      child: Column(
        children: [
          // ================= TITLE =================
          TextFormField(
            controller: titleCtrl,

            decoration: _inputDecoration(
              label: 'Event Title',
              icon: Icons.event_outlined,
            ),

            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title required' : null,
          ),

          const SizedBox(height: 16),

          // ================= DESCRIPTION =================
          TextFormField(
            controller: descCtrl,
            maxLines: 4,

            decoration: _inputDecoration(
              label: 'Description',
              icon: Icons.description_outlined,
            ),

            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Description required' : null,
          ),

          const SizedBox(height: 20),

          // ================= DATE =================
          FormField<DateTime>(
            initialValue: selectedDate,

            validator: (_) => selectedDate == null ? 'Date required' : null,

            builder: (field) {
              return InkWell(
                onTap: () => onPickDate(field),

                borderRadius: BorderRadius.circular(14),

                child: InputDecorator(
                  decoration: _inputDecoration(
                    label: 'Event Date',
                    icon: Icons.calendar_today_outlined,
                  ).copyWith(errorText: field.errorText),

                  child: Text(
                    selectedDate == null
                        ? 'Select date'
                        : formatDate(selectedDate!),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // ================= START TIME =================
          TextFormField(
            controller: startTimeCtrl,
            readOnly: true,

            decoration: _inputDecoration(
              label: 'Start Time',
              icon: Icons.access_time,
            ),

            onTap: () => onPickTime(startTimeCtrl),

            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Start time required' : null,
          ),

          const SizedBox(height: 16),

          // ================= END TIME =================
          TextFormField(
            controller: endTimeCtrl,
            readOnly: true,

            decoration: _inputDecoration(
              label: 'End Time',
              icon: Icons.access_time_filled,
            ),

            onTap: () => onPickTime(endTimeCtrl),

            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'End time required';
              }

              final start = startTimeCtrl.text.trim();

              if (start.isNotEmpty) {
                // Compare HH:mm strings safely
                if (start.compareTo(v) >= 0) {
                  return 'End time must be after start time';
                }
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          // ================= LOCATION =================
          TextFormField(
            controller: locationCtrl,

            decoration: _inputDecoration(
              label: 'Location',
              icon: Icons.location_on_outlined,
            ),

            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Location required' : null,
          ),
        ],
      ),
    );
  }
}
