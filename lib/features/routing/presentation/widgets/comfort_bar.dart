import 'package:flutter/material.dart';

/// A single labeled progress row in the Comfort Analysis card — used for
/// both Shade/Sun (percent-driven) and Wind (a qualitative label, so it
/// gets a fixed illustrative fill rather than a real percentage).
class ComfortBar extends StatelessWidget {
  const ComfortBar({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.trailing,
    required this.color,
  });

  final String emoji;
  final String label;
  final double value; // 0-1
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0xFFEDF0EF),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(trailing,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}
