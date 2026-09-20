import 'package:flutter/material.dart';

class FindRouteCta extends StatelessWidget {
  const FindRouteCta({super.key, required this.onTap});

  final VoidCallback onTap;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryGreen, primaryGreenLight]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
              child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Best Route',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Comfort-optimized · Weather-aware',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}
