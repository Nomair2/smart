import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
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

ManeuverStyle maneuverStyle(ManeuverType type, AppLocalizations l10n) {
  switch (type) {
    case ManeuverType.start:
      return ManeuverStyle(
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFF4C6FE0),
        backgroundColor: const Color(0xFFEAEEFD),
        label: l10n.maneuverStart,
      );
    case ManeuverType.left:
      return ManeuverStyle(
        icon: Icons.turn_left_rounded,
        color: const Color(0xFF7B4CE0),
        backgroundColor: const Color(0xFFF1EAFD),
        label: l10n.maneuverTurnLeft,
      );
    case ManeuverType.right:
      return ManeuverStyle(
        icon: Icons.turn_right_rounded,
        color: const Color(0xFFB8860B),
        backgroundColor: const Color(0xFFFDF6E3),
        label: l10n.maneuverTurnRight,
      );
    case ManeuverType.straight:
      return ManeuverStyle(
        icon: Icons.straight_rounded,
        color: const Color(0xFF1E5B3D),
        backgroundColor: const Color(0xFFEAF3EE),
        label: l10n.maneuverContinueStraight,
      );
    case ManeuverType.arrive:
      return ManeuverStyle(
        icon: Icons.flag_rounded,
        color: const Color(0xFF1E5B3D),
        backgroundColor: const Color(0xFFEAF3EE),
        label: l10n.maneuverArrived,
      );
  }
}
