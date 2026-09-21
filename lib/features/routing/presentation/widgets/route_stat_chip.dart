import 'package:flutter/material.dart';

class RouteStatChip extends StatelessWidget {
  const RouteStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 1),
            Text(label, style: TextStyle(fontSize: 10.5, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
