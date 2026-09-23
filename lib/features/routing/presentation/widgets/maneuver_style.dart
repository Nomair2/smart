import 'package:flutter/material.dart';

import '../../domain/entities/guidance_instruction.dart';

/// Icon/color/label for a [ManeuverType], shared between [CurrentStepCard]
/// and [GuideStepTile] so both cards agree on what a "turn left" looks
/// like. Colors reuse the palette already established elsewhere (comfort
/// green, balanced purple, shortest/summer amber) rather than inventing a
/// new one for this screen.
class ManeuverStyle {
  const ManeuverStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String label;
}

ManeuverStyle maneuverStyle(ManeuverType type) {
  switch (type) {
    case ManeuverType.start:
      return const ManeuverStyle(
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF4C6FE0),
        backgroundColor: Color(0xFFEAEEFD),
        label: 'START',
      );
    case ManeuverType.left:
      return const ManeuverStyle(
        icon: Icons.turn_left_rounded,
        color: Color(0xFF7B4CE0),
        backgroundColor: Color(0xFFF1EAFD),
        label: 'TURN LEFT',
      );
    case ManeuverType.right:
      return const ManeuverStyle(
        icon: Icons.turn_right_rounded,
        color: Color(0xFFB8860B),
        backgroundColor: Color(0xFFFDF6E3),
        label: 'TURN RIGHT',
      );
    case ManeuverType.straight:
      return const ManeuverStyle(
        icon: Icons.straight_rounded,
        color: Color(0xFF1E5B3D),
        backgroundColor: Color(0xFFEAF3EE),
        label: 'CONTINUE STRAIGHT',
      );
    case ManeuverType.arrive:
      return const ManeuverStyle(
        icon: Icons.flag_rounded,
        color: Color(0xFF1E5B3D),
        backgroundColor: Color(0xFFEAF3EE),
        label: 'ARRIVED',
      );
  }
}
