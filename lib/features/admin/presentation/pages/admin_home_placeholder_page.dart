import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

/// Stand-in landing screen for admins (report section 3.3.2-B: account
/// management, campus endpoints, path segments, availability, monitoring).
/// Swap this out once the real admin dashboard is built.
class AdminHomePlaceholderPage extends StatelessWidget {
  const AdminHomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = fb.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Masar KKU — Admin')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 40,
              color: Color(0xFF1E5B3D),
            ),
            const SizedBox(height: 12),
            Text('Signed in as admin (${user?.email ?? 'unknown'})'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => fb.FirebaseAuth.instance.signOut(),
              child: const Text('Sign out for admin'),
            ),
          ],
        ),
      ),
    );
  }
}
