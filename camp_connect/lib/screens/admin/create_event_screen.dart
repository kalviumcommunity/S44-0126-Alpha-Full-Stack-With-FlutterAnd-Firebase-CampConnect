import 'package:flutter/material.dart';
import 'package:camp_connect/services/event_service.dart';

class AdminCreateEventScreen extends StatefulWidget {
  const AdminCreateEventScreen({super.key});

  @override
  State<AdminCreateEventScreen> createState() => _AdminCreateEventScreenState();
}

class _AdminCreateEventScreenState extends State<AdminCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  // 🔹 SAME INPUT DECORATION AS SIGNUP SCREEN
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

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    await EventService().createEvent(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      date: selectedDate!,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Create Event'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Event Title
                          TextFormField(
                            controller: titleCtrl,
                            decoration: _inputDecoration(
                              label: 'Event Title',
                              icon: Icons.event_outlined,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Title required'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // 🔹 Description
                          TextFormField(
                            controller: descCtrl,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              label: 'Description',
                              icon: Icons.description_outlined,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔹 Location
                          TextFormField(
                            controller: locationCtrl,
                            decoration: _inputDecoration(
                              label: 'Location',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Location required'
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // 🔹 Date Picker (Styled like input)
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedDate == null
                                        ? 'Pick Event Date'
                                        : selectedDate!
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (selectedDate == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Please select a date',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔹 STICKY CREATE BUTTON (same as Signup)
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
