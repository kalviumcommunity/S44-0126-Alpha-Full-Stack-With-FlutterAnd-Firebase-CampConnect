import 'package:flutter/material.dart';

import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/date_utils.dart';

class AdminCreateEventScreen extends StatefulWidget {
  const AdminCreateEventScreen({super.key});

  @override
  State<AdminCreateEventScreen> createState() => _AdminCreateEventScreenState();
}

class _AdminCreateEventScreenState extends State<AdminCreateEventScreen> {
  // ================= FORM =================

  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  // ================= STATE =================

  DateTime? selectedDate;
  bool isSubmitted = false;

  // ================= LIFECYCLE =================

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();

    super.dispose();
  }

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

  // ================= DATE PICKER =================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,

      firstDate: DateTime.now(),
      lastDate: DateTime(2100),

      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= CREATE EVENT =================

  Future<void> _createEvent() async {
    setState(() => isSubmitted = true);

    final bool isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    try {
      await EventService().createEvent(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        date: selectedDate!,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
    }
  }

  // ================= AUTH =================

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

        return _buildAdminUI(context);
      },
    );
  }

  // ================= UI =================

  Widget _buildAdminUI(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text('Create Event'),

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

                    child: Form(
                      key: _formKey,

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

                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Title required'
                                : null,
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

                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Description required'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // ================= LOCATION =================
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

                          // ================= DATE =================
                          FormField<DateTime>(
                            validator: (_) =>
                                selectedDate == null ? 'Date required' : null,

                            builder: (field) {
                              return InkWell(
                                onTap: () async {
                                  await _pickDate();
                                  field.didChange(selectedDate);
                                },

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

                                    style: const TextStyle(fontSize: 15),
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

                // ================= SUBMIT =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),

                  child: SizedBox(
                    width: size.width > 720 ? 400 : double.infinity,

                    height: 52,

                    child: ElevatedButton(
                      onPressed: _createEvent,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),

                      child: const Text(
                        'Create Event',

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
