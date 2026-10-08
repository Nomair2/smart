import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/route_optimization_goal.dart';
import '../../domain/entities/route_result.dart';

class AlternativeRouteRow extends StatelessWidget {
  const AlternativeRouteRow({super.key, required this.alternative});

  final AlternativeRouteSummary alternative;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isShortest = alternative.goal == RouteOptimizationGoal.shortest;
    final minutes = (alternative.estimatedTime.inSeconds / 60).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Was hardcoded Colors.white / Color(0xFFEDF0EF) border.
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                Text(isShortest ? l10n.shortestPathLabel : l10n.balancedRouteLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  l10n.altRouteSummary(alternative.distanceMeters.round(), minutes, alternative.shadePercent.round()),
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
              isShortest ? l10n.fastBadge : l10n.balancedBadge,
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
