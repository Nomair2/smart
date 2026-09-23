import 'package:flutter/material.dart';

import '../../domain/entities/guidance_instruction.dart';
import 'maneuver_style.dart';

/// The prominent "you are here" card — always shows the current instruction
/// prominently, matching the mockup's green step card.
class CurrentStepCard extends StatelessWidget {
  const CurrentStepCard({
    super.key,
    required this.instruction,
    required this.stepNumber,
    required this.totalSteps,
  });

  final GuidanceInstruction instruction;
  final int stepNumber;
  final int totalSteps;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    final style = maneuverStyle(instruction.action);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, primaryGreenLight],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(style.icon, color: primaryGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STEP $stepNumber OF $totalSteps',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6)),
                const SizedBox(height: 4),
                Text(instruction.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.3)),
                if (instruction.legDistanceMeters > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.social_distance_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 5),
                      Text('${instruction.legDistanceMeters.round()} m ahead',
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
