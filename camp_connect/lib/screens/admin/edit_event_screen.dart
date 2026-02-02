import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/date_utils.dart';

class AdminEditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const AdminEditEventScreen({super.key, required this.event});

  @override
  State<AdminEditEventScreen> createState() => _AdminEditEventScreenState();
}

class _AdminEditEventScreenState extends State<AdminEditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController locationCtrl;

  DateTime? selectedDate;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.event['title']);
    descCtrl = TextEditingController(text: widget.event['description']);
    locationCtrl = TextEditingController(text: widget.event['location']);
    selectedDate = widget.event['date'];
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      field.didChange(picked);
    }
  }

  Future<void> _updateEvent() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await EventService().updateEvent(
        eventId: widget.event['id'],
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        date: selectedDate!,
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isCancelled = widget.event['status'] == 'cancelled';

    return StreamBuilder<bool>(
      stream: authService.isAdminStream(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

        if (!isAdmin) {
          return const Scaffold(
            body: Center(child: Text('Unauthorized access')),
          );
        }

        if (isCancelled) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Cancelled events cannot be edited',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return _buildUI(context);
      },
    );
  }

  Widget _buildUI(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // Title
                          TextFormField(
                            controller: titleCtrl,
                            decoration: _inputDecoration(
                              label: 'Event Title',
                              icon: Icons.event_outlined,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Title required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: descCtrl,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              label: 'Description',
                              icon: Icons.description_outlined,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Description required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Location
                          TextFormField(
                            controller: locationCtrl,
                            decoration: _inputDecoration(
                              label: 'Location',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Location required'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Date
                          FormField<DateTime>(
                            initialValue: selectedDate,
                            validator: (_) =>
                                selectedDate == null ? 'Date required' : null,
                            builder: (field) {
                              return InkWell(
                                onTap: () => _pickDate(field),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Update Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: size.width > 720 ? 400 : double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _updateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Update Event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
