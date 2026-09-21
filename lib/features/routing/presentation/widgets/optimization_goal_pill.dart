import 'package:flutter/material.dart';

import '../../domain/entities/route_optimization_goal.dart';

class OptimizationGoalPill extends StatelessWidget {
  const OptimizationGoalPill({super.key, required this.goal, required this.selected, required this.onTap});

  final RouteOptimizationGoal goal;
  final bool selected;
  final VoidCallback onTap;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  String get _emoji {
    switch (goal) {
      case RouteOptimizationGoal.comfort:
        return '\ud83d\ude0a';
      case RouteOptimizationGoal.shortest:
        return '\u26a1';
      case RouteOptimizationGoal.balanced:
        return '\u2696\ufe0f';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primaryGreen : const Color(0xFFF6F8F7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(goal.label,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
