import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

/// Stand-in for the real "Main Student Interface" (report section 3.7.4).
/// Just enough to confirm the auth loop actually works end to end — swap
/// this out once the home dashboard feature is built.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = fb.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Path')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Signed in as ${user?.email ?? 'unknown'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => fb.FirebaseAuth.instance.signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
