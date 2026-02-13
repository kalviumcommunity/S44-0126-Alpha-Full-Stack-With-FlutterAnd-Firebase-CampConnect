import 'package:flutter/material.dart';

/// Picks time and puts it in controller (HH:mm)
Future<void> pickTime(
  BuildContext context,
  TextEditingController controller,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked == null) return;

  controller.text =
      '${picked.hour.toString().padLeft(2, '0')}:'
      '${picked.minute.toString().padLeft(2, '0')}';
}

/// Picks date and updates form field + state
Future<void> pickDate({
  required BuildContext context,
  required DateTime? currentDate,
  required void Function(DateTime) onSelected,
  required FormFieldState<DateTime> field,
}) async {
  final picked = await showDatePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    initialDate: currentDate ?? DateTime.now(),
  );

  if (picked == null) return;

  onSelected(picked);
  field.didChange(picked);
}
