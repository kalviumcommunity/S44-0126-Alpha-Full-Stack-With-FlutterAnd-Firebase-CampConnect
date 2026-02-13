import 'package:flutter/material.dart';

import 'package:camp_connect/services/auth_service.dart';
import 'package:camp_connect/utils/dummy_uploader.dart';

class AdminDummyUploadButton extends StatelessWidget {
  const AdminDummyUploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: AuthService().streamUserProfile(),

      builder: (context, snapshot) {
        final role = snapshot.data?['role'];

        // Hide for non-admin
        if (role != 'admin') {
          return const SizedBox();
        }

        return ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload, size: 18),

          label: const Text(
            'Upload Dummy Events',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 1,

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          onPressed: () async {
            try {
              await DummyUploader.uploadAll();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dummy events uploaded')),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
        );
      },
    );
  }
}
