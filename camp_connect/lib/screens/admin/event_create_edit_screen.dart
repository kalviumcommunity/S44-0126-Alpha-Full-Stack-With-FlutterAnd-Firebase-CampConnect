import 'package:camp_connect/services/event_service.dart';
import 'package:camp_connect/utils/picker_utils.dart';
import 'package:camp_connect/widgets/admin/event/form/admin_event_create_edit_layout.dart';
import 'package:camp_connect/widgets/admin/common/admin_guard.dart';
import 'package:camp_connect/widgets/admin/event/form/admin_event_form.dart';
import 'package:flutter/material.dart';

enum EventMode { create, edit }

class AdminEventScreen extends StatefulWidget {
  final EventMode mode;
  final Map<String, dynamic>? event;

  const AdminEventScreen({super.key, required this.mode, this.event});

  @override
  State<AdminEventScreen> createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends State<AdminEventScreen> {
  // ================= FORM =================

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController startTimeCtrl;
  late final TextEditingController endTimeCtrl;

  // ================= STATE =================

  DateTime? selectedDate;
  bool isSubmitted = false;

  bool get isEdit => widget.mode == EventMode.edit;

  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();

    if (isEdit && widget.event != null) {
      final event = widget.event!;

      titleCtrl = TextEditingController(text: event['title']);
      descCtrl = TextEditingController(text: event['description']);
      locationCtrl = TextEditingController(text: event['location']);
      startTimeCtrl = TextEditingController(text: event['startTime']);
      endTimeCtrl = TextEditingController(text: event['endTime']);

      selectedDate = event['date'];
    } else {
      titleCtrl = TextEditingController();
      descCtrl = TextEditingController();
      locationCtrl = TextEditingController();
      startTimeCtrl = TextEditingController();
      endTimeCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();

    super.dispose();
  }

  // ================= SAVE EVENT =================

  Future<void> _saveEvent() async {
    setState(() => isSubmitted = true);

    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEdit) {
        await EventService().updateEvent(
          eventId: widget.event!['id'],
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          date: selectedDate!,
          startTime: startTimeCtrl.text.trim(),
          endTime: endTimeCtrl.text.trim(),
        );
      } else {
        await EventService().createEvent(
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          location: locationCtrl.text.trim(),
          date: selectedDate!,
          startTime: startTimeCtrl.text.trim(),
          endTime: endTimeCtrl.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      if (isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Failed to update event. Please try again.'
                : 'Failed to create event. Please try again.',
          ),
        ),
      );
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // Prevent editing cancelled event
    if (isEdit && widget.event?['status'] == 'cancelled') {
      return const Scaffold(
        body: Center(child: Text('Cancelled events cannot be edited')),
      );
    }

    return AdminGuard(
      child: AdminEventLayout(
        title: isEdit ? 'Edit Event' : 'Create Event',

        buttonLabel: isEdit ? 'Update Event' : 'Create Event',

        onSubmit: _saveEvent,

        form: AdminEventForm(
          formKey: _formKey,

          titleCtrl: titleCtrl,
          descCtrl: descCtrl,
          locationCtrl: locationCtrl,
          startTimeCtrl: startTimeCtrl,
          endTimeCtrl: endTimeCtrl,

          selectedDate: selectedDate,

          onPickTime: (ctrl) => pickTime(context, ctrl),

          onPickDate: (field) => pickDate(
            context: context,
            currentDate: selectedDate,
            field: field,
            onSelected: (date) {
              setState(() => selectedDate = date);
            },
          ),

          isSubmitted: isSubmitted,
        ),
      ),
    );
  }
}
