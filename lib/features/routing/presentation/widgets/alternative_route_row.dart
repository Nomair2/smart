import 'package:flutter/material.dart';

import '../../domain/entities/route_optimization_goal.dart';
import '../../domain/entities/route_result.dart';

class AlternativeRouteRow extends StatelessWidget {
  const AlternativeRouteRow({super.key, required this.alternative});

  final AlternativeRouteSummary alternative;

  @override
  Widget build(BuildContext context) {
    final isShortest = alternative.goal == RouteOptimizationGoal.shortest;
    final minutes = (alternative.estimatedTime.inSeconds / 60).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF0EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(0xFFEAF3EE), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF1E5B3D)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isShortest ? 'Shortest Path' : 'Balanced Route',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${alternative.distanceMeters.round()} m · $minutes min · ${alternative.shadePercent.round()}% shade',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isShortest ? const Color(0xFFFDF6E3) : const Color(0xFFF1EAFD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isShortest ? '\u26a1 Fast' : '\u2696\ufe0f Balanced',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isShortest ? const Color(0xFFB8860B) : const Color(0xFF7B4CE0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
