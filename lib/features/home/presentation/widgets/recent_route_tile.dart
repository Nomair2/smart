import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/recent_route_summary.dart';

class RecentRouteTile extends StatelessWidget {
  const RecentRouteTile({super.key, required this.route, this.onTap});

  final RecentRouteSummary route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSummer = route.seasonMode == SeasonMode.summer;
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
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFEAF3EE), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_on_rounded, color: Color(0xFF1E5B3D), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${route.originName} \u2192 ${route.destinationName}',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${route.walkMinutes} min walk · ${_relativeTime(route.requestedAt)}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSummer ? const Color(0xFFFDF6E3) : const Color(0xFFEAEEFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSummer ? '\u2600\ufe0f Summer' : '\u2744\ufe0f Winter',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSummer ? const Color(0xFFB8860B) : const Color(0xFF4C6FE0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
