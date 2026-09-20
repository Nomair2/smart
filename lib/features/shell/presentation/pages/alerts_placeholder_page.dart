import 'package:flutter/material.dart';

/// Stand-in for requirement A11 (notifications — report section 3.7.10).
/// Swap out once that feature is built.
class AlertsPlaceholderPage extends StatelessWidget {
  const AlertsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 40, color: Color(0xFF1E5B3D)),
                const SizedBox(height: 12),
                Text('Notifications are coming soon', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
