import 'package:flutter/material.dart';

import '../../domain/entities/guidance_instruction.dart';
import 'maneuver_style.dart';

/// One row in the upcoming-steps list. Tappable — tapping marks that step
/// as reached (see [RouteGuideCubit.advanceTo]).
class GuideStepTile extends StatelessWidget {
  const GuideStepTile({super.key, required this.instruction, this.onTap});

  final GuidanceInstruction instruction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = maneuverStyle(instruction.action);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDF0EF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: style.backgroundColor, borderRadius: BorderRadius.circular(11)),
              child: Icon(style.icon, size: 19, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(style.label,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: style.color)),
                      const Spacer(),
                      if (instruction.legDistanceMeters > 0)
                        Text('${instruction.legDistanceMeters.round()} m',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(instruction.text,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
