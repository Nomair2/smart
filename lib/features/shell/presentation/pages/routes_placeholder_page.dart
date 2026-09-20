import 'package:flutter/material.dart';

/// Stand-in for route selection + the optimal route display (report
/// sections 3.7.5/3.7.6 — requirements A4/A6). Swap out once that feature
/// is built; the shell's Routes tab already points here.
class RoutesPlaceholderPage extends StatelessWidget {
  const RoutesPlaceholderPage({super.key});

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
                const Icon(Icons.map_rounded, size: 40, color: Color(0xFF1E5B3D)),
                const SizedBox(height: 12),
                Text('Route selection is coming soon', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
